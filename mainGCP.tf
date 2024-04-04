provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project_id
  region      = var.gcp_project_region
}

resource "google_compute_network" "vpc" {
  name                            = var.vpc_name
  auto_create_subnetworks         = var.vpc_create_subnets_automatically
  routing_mode                    = var.routing_mode_for_vpc
  delete_default_routes_on_create = var.vpc_delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp" {
  name                     = var.webapp_subnet_name
  ip_cidr_range            = var.webapp_subnet_ip_cidr_range
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = var.subnet_private_ip_google_access
  depends_on               = [google_compute_network.vpc]
}

resource "google_compute_subnetwork" "db" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_ip_cidr_range
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = var.subnet_private_ip_google_access
  depends_on               = [google_compute_network.vpc]
}

resource "google_compute_route" "webapp_subnet_route" {
  network          = google_compute_network.vpc.self_link
  name             = var.webapp_subnet_route_name
  dest_range       = var.webapp_subnet_route_dest_range
  next_hop_gateway = var.webapp_subnet_route_next_hop_gateway
  priority         = var.webapp_subnet_route_priority
  depends_on       = [google_compute_network.vpc]
}

# Refrence taken from https://medium.com/google-cloud/terraform-on-google-cloud-v1-2-deploying-postgresql-with-github-actions-e7009cb04d22
resource "google_compute_global_address" "app_global_address" {
  name          = var.global_address_name
  address_type  = var.global_address_type
  purpose       = var.global_address_purpose
  network       = google_compute_network.vpc.self_link
  prefix_length = var.global_address_prefix_length
  depends_on    = [google_compute_network.vpc]
}

# Reference taken from https://medium.com/google-cloud/terraform-on-google-cloud-v1-2-deploying-postgresql-with-github-actions-e7009cb04d22
# and https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection

resource "google_service_networking_connection" "private_connection_for_vpc" {
  network                 = google_compute_network.vpc.self_link
  service                 = var.google_service_networking_connection_service_name
  reserved_peering_ranges = [google_compute_global_address.app_global_address.name]
  deletion_policy         = var.google_service_networking_connection_deletion_policy
  depends_on              = [google_compute_global_address.app_global_address]
}

# Refernece for random_id taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user
resource "random_id" "suffix_for_db_instance" {
  byte_length = var.random_id_suffix_for_db_instance_byte_length
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
# and https://medium.com/google-cloud/terraform-on-google-cloud-v1-2-deploying-postgresql-with-github-actions-e7009cb04d22

resource "google_sql_database_instance" "postgres_db" {
  name                = "postgres-db-instance-${random_id.suffix_for_db_instance.hex}"
  project             = var.gcp_project_id
  region              = var.gcp_project_region
  database_version    = var.google_sql_database_instance_database_version
  deletion_protection = var.google_sql_database_instance_deletion_policy
  depends_on          = [google_service_networking_connection.private_connection_for_vpc, google_pubsub_subscription.verify_email_subscription, google_pubsub_topic_iam_binding.topic_binding]

  settings {
    tier              = var.google_sql_database_instance_tier
    availability_type = var.google_sql_database_instance_availability_type
    disk_type         = var.google_sql_database_instance_disk_type
    disk_size         = var.google_sql_database_instance_disk_size
    ip_configuration {
      ipv4_enabled                                  = var.google_sql_database_instance_ipv4_enabled
      private_network                               = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = var.google_sql_database_instance_private_path_for_GCP_services
    }
  }
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database
resource "google_sql_database" "database" {
  name       = var.google_sql_database_name
  instance   = google_sql_database_instance.postgres_db.name
  depends_on = [google_sql_database_instance.postgres_db]
}

# Reference taken https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "db_password" {
  length           = var.random_password_length
  override_special = var.random_password_override_special
  special          = var.random_password_special
}

# Reference taken from https://medium.com/google-cloud/terraform-on-google-cloud-v1-2-deploying-postgresql-with-github-actions-e7009cb04d22
resource "google_sql_user" "users" {
  name       = var.google_sql_user_name
  instance   = google_sql_database_instance.postgres_db.name
  password   = random_password.db_password.result
  depends_on = [google_sql_database_instance.postgres_db, random_password.db_password]
}

# Reference from https://medium.com/google-cloud/terraform-on-google-cloud-v1-1-deploying-vm-with-github-actions-446bc1061420
resource "google_compute_firewall" "webapp_firewall" {
  name    = var.gcp_firwall_name
  network = google_compute_network.vpc.self_link

  allow {
    protocol = var.gcp_firewall_allowed_protocol
    ports    = var.gcp_firewall_ports
  }

  source_ranges = var.gcp_firewall_source_ranges
  target_tags   = var.vm_firewall_target_tags
  priority      = var.gcp_firewall_priority
  depends_on    = [google_compute_network.vpc]
}

resource "google_compute_firewall" "webapp_deny_firewall" {
  name    = var.gcp_deny_firewall_name
  network = google_compute_network.vpc.self_link

  deny {
    protocol = var.gcp_deny_firewall_allowed_protocol
    ports    = var.gcp_deny_firewall_ports
  }

  source_ranges = var.gcp_deny_firewall_source_ranges
  target_tags   = var.vm_firewall_target_tags
  depends_on    = [google_compute_network.vpc]
}

resource "google_compute_firewall" "loadbalancer_firewall" {
  name      = var.loadbalancer_firewall_name
  network   = google_compute_network.vpc.self_link
  direction = var.loadbalancer_firewall_direction

  allow {
    protocol = var.loadbalancer_firewall_protocol
    ports    = var.loadbalancer_firewall_ports
  }

  source_ranges = var.loadbalancer_firewall_source_ranges
  target_tags   = var.vm_firewall_target_tags
  priority      = var.loadbalancer_firewall_priority
  depends_on    = [google_compute_network.vpc]
}

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "service_account" {
  account_id                   = var.service_account_id
  display_name                 = var.service_account_display_name
  create_ignore_already_exists = var.service_account_create_ignore_already_exists
}

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_binding
resource "google_project_iam_binding" "logging_admin_for_service_account" {
  project = var.gcp_project_id
  role    = var.logging_service_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "monitoring_metric_writer_for_service_account" {
  project = var.gcp_project_id
  role    = var.monitoring_service_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.gcp_project_id
  role    = var.pubsub_publisher_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "token_creator_role" {
  project = var.gcp_project_id
  role    = var.token_creator_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "developer_role" {
  project = var.gcp_project_id
  role    = var.cloud_functions_developer_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "cloud_run_invoker_role" {
  project = var.gcp_project_id
  role    = var.cloud_runner_invoker_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_cloud_run_service_iam_member" "cloud_run_invoker" {
  project  = google_cloudfunctions2_function.serverless-v2.project
  location = google_cloudfunctions2_function.serverless-v2.location
  service  = google_cloudfunctions2_function.serverless-v2.name
  role     = var.cloud_runner_invoker_role
  member   = "serviceAccount:${google_service_account.service_account.email}"

  depends_on = [google_service_account.service_account, google_cloudfunctions2_function.serverless-v2]
}

resource "google_pubsub_schema" "schema_definition" {
  name       = var.pubsub_values.schema_name
  type       = var.pubsub_values.schema_type
  definition = var.pubsub_values.schema_definition
}

resource "google_pubsub_topic" "verify_topic" {
  project                    = var.gcp_project_id
  name                       = var.pubsub_values.topic_name
  message_retention_duration = var.pubsub_values.topic_message_retention

  schema_settings {
    schema   = "projects/${var.gcp_project_id}/schemas/${google_pubsub_schema.schema_definition.name}"
    encoding = var.pubsub_values.topic_settings_encoding
  }

  depends_on = [google_pubsub_schema.schema_definition]
}


resource "google_pubsub_topic_iam_binding" "topic_binding" {
  project = google_pubsub_topic.verify_topic.project
  topic   = google_pubsub_topic.verify_topic.name
  role    = var.pubsub_publisher_role
  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account, google_pubsub_topic.verify_topic]
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = var.pubsub_values.subscription_name
  topic = google_pubsub_topic.verify_topic.name

  depends_on = [google_pubsub_topic.verify_topic]
}

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector
resource "google_vpc_access_connector" "serverless_connector" {
  name           = var.serverless_vpc_access.name
  ip_cidr_range  = var.serverless_vpc_access.ip_cidr_range
  network        = google_compute_network.vpc.self_link
  machine_type   = var.serverless_vpc_access.machine_type
  min_instances  = var.serverless_vpc_access.min_instances
  max_instances  = var.serverless_vpc_access.max_instances
  max_throughput = var.serverless_vpc_access.max_throughput
  region         = var.gcp_project_region

  depends_on = [google_compute_network.vpc, google_service_networking_connection.private_connection_for_vpc]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_template
resource "google_compute_region_instance_template" "webapp_vm_instance" {
  name           = var.instance_template_name
  machine_type   = var.instance_template_machine_type
  region         = var.gcp_project_region
  can_ip_forward = var.instance_template_can_ip_forward

  disk {
    source_image = var.instance_image_from_packer
    auto_delete  = var.instance_template_name_auto_delete
    boot         = var.instance_template_name_boot
    disk_type    = var.instance_image_type
    disk_size_gb = var.instance_image_disk_size
  }

  reservation_affinity {
    type = var.instance_template_affinity_type
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {}
  }

  scheduling {
    preemptible       = var.instance_template_scheduling_preemptible
    automatic_restart = var.instance_template_scheduling_automatic_restart
  }

  #  Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#service_account
  service_account {
    email  = google_service_account.service_account.email
    scopes = var.service_account_scopes
  }

  labels = {
    gce-service-proxy = "on"
  }

  tags       = var.vm_firewall_target_tags
  depends_on = [google_compute_subnetwork.webapp, google_compute_firewall.webapp_firewall, google_compute_firewall.webapp_deny_firewall, google_sql_database_instance.postgres_db, google_sql_user.users, google_project_iam_binding.logging_admin_for_service_account, google_project_iam_binding.monitoring_metric_writer_for_service_account, google_pubsub_topic.verify_topic, google_pubsub_subscription.verify_email_subscription, google_vpc_access_connector.serverless_connector, google_compute_firewall.loadbalancer_firewall]

  metadata = {
    startup-script = <<-EOT
#!/bin/bash

set -e

ENV_FILE="/opt/csye6225/webapp/.env"
SERVER_PORT=8080
DATABASE_NAME=${google_sql_database.database.name}
DATABASE_USER_NAME=${google_sql_user.users.name}
DATABASE_PASSWORD=${google_sql_user.users.password}
DATABASE_HOST_URL=${google_sql_database_instance.postgres_db.private_ip_address}
IS_TEST_ENVIROMENT=false
TOPIC_NAME="verify_email"

if [ -f "$ENV_FILE"  ]; then
    echo "Env file exists."
    sudo sed -i "s/^SERVER_PORT=.*/SERVER_PORT=$SERVER_PORT/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_NAME=.*/DATABASE_NAME=$DATABASE_NAME/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_USER_NAME=.*/DATABASE_USER_NAME=$DATABASE_USER_NAME/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$DATABASE_PASSWORD/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_HOST_URL=.*/DATABASE_HOST_URL=$DATABASE_HOST_URL/" "$ENV_FILE"
    sudo sed -i "s/^IS_TEST_ENVIROMENT=.*/IS_TEST_ENVIROMENT=$IS_TEST_ENVIROMENT/" "$ENV_FILE"
    sudo sed -i "s/^TOPIC_NAME=.*/TOPIC_NAME=$TOPIC_NAME/" "$ENV_FILE"
else
    echo "File does not exist."
    sudo sh -c "echo 'SERVER_PORT=$SERVER_PORT' > $ENV_FILE"
    sudo sh -c "echo 'DATABASE_NAME=$DATABASE_NAME' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_USER_NAME=$DATABASE_USER_NAME' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_PASSWORD=$DATABASE_PASSWORD' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_HOST_URL=$DATABASE_HOST_URL' >> $ENV_FILE"
    sudo sh -c "echo 'IS_TEST_ENVIROMENT=$IS_TEST_ENVIROMENT' >> $ENV_FILE"
    sudo sh -c "echo 'TOPIC_NAME=$TOPIC_NAME' >> $ENV_FILE"
fi

sudo systemctl daemon-reload
sudo systemctl restart webapp

sudo systemctl daemon-reload

echo "Test=Working" >> /tmp/.testEnv

EOT
  }
}

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function#environment_variables
resource "google_cloudfunctions2_function" "serverless-v2" {
  project     = var.gcp_project_id
  location    = var.gcp_project_region
  name        = var.serverless_cloud_function.name
  description = var.serverless_cloud_function.description

  build_config {
    runtime     = var.serverless_cloud_function.runtime
    entry_point = var.serverless_cloud_function.entry_point
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = var.serverless_cloud_function.bucket_source
        object = var.serverless_cloud_function.object_source
      }
    }
  }

  service_config {
    timeout_seconds = var.serverless_cloud_function.timeout
    environment_variables = {
      MAILGUN_API_KEY    = var.mail_gun_api_key
      DATABASE_NAME      = var.google_sql_database_name
      DATABASE_USER_NAME = var.google_sql_user_name
      DATABASE_PASSWORD  = random_password.db_password.result
      DATABASE_HOST_URL  = google_sql_database_instance.postgres_db.private_ip_address
    }
    available_memory                 = var.serverless_cloud_function.memory
    max_instance_request_concurrency = var.serverless_cloud_function.max_instance_concurrency
    min_instance_count               = var.serverless_cloud_function.min_instance_count
    max_instance_count               = var.serverless_cloud_function.max_instance_count
    available_cpu                    = var.serverless_cloud_function.available_cpu
    ingress_settings                 = var.serverless_cloud_function.ingress_settings

    vpc_connector = google_vpc_access_connector.serverless_connector.name

    vpc_connector_egress_settings  = var.serverless_cloud_function.vpc_connector_egress_settings
    service_account_email          = google_service_account.service_account.email
    all_traffic_on_latest_revision = var.serverless_cloud_function.all_traffic_on_latest_revision
  }

  event_trigger {
    trigger_region        = var.gcp_project_region
    event_type            = var.serverless_cloud_function.event_type
    pubsub_topic          = "projects/${var.gcp_project_id}/topics/${google_pubsub_topic.verify_topic.name}"
    retry_policy          = var.serverless_cloud_function.retry_policy
    service_account_email = google_service_account.service_account.email
  }

  depends_on = [google_sql_database_instance.postgres_db, google_pubsub_topic.verify_topic, google_compute_region_instance_template.webapp_vm_instance]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate
resource "google_compute_managed_ssl_certificate" "ssl_certificates" {
  name = var.ssl_certificate_name

  managed {
    domains = [var.webapp_domain_name]
  }
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
resource "google_compute_global_address" "default_forward_address" {
  project    = var.gcp_project_id
  name       = var.default_forward_address_name
  depends_on = [google_compute_network.vpc]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check
resource "google_compute_health_check" "health_check" {
  name                = var.instance_health_check_name
  check_interval_sec  = var.instance_health_check_interval_sec
  timeout_sec         = var.instance_health_check_timeout_sec
  healthy_threshold   = var.instance_health_check_healthy_threshold
  unhealthy_threshold = var.instance_health_check_unhealthy_threshold

  http_health_check {
    port_name    = var.instance_health_check_port_name
    request_path = var.instance_health_check_request_path
    port         = var.instance_health_check_port
  }
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager
resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  name                             = var.instance_group_manager_name
  base_instance_name               = var.instance_group_manager_base_instance_name
  description                      = var.instance_group_manager_description
  region                           = var.gcp_project_region
  distribution_policy_zones        = var.instance_group_manager_distribution_policy_zones
  distribution_policy_target_shape = var.instance_group_manager_distribution_policy_target_shape

  version {
    instance_template = google_compute_region_instance_template.webapp_vm_instance.self_link
  }

  named_port {
    name = var.instance_group_manager_port_name
    port = var.instance_group_manager_port
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.self_link
    initial_delay_sec = var.instance_group_manager_port_healing_initial_delay
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [google_compute_region_instance_template.webapp_vm_instance, google_compute_health_check.health_check]
}

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  region = var.gcp_project_region
  target = google_compute_region_instance_group_manager.instance_group_manager.self_link

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.autoscaler_min_replicas
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.autoscaler_cpu_target
    }
  }

  depends_on = [google_compute_region_instance_group_manager.instance_group_manager]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service
resource "google_compute_backend_service" "loadbalancer" {
  name          = var.loadbalancer_name
  health_checks = [google_compute_health_check.health_check.self_link]
  enable_cdn    = var.loadbalancer_enable_cdn

  backend {
    group           = google_compute_region_instance_group_manager.instance_group_manager.instance_group
    balancing_mode  = var.loadbalancer_balancing_mode
    capacity_scaler = var.loadbalancer_capacity_scaler
  }

  protocol              = var.loadbalancer_protocol
  port_name             = var.loadbalancer_port_name
  load_balancing_scheme = var.loadbalancer_load_balancing_scheme
  timeout_sec           = var.loadbalancer_timeout_sec

  depends_on = [google_compute_region_instance_group_manager.instance_group_manager, google_compute_health_check.health_check]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map
resource "google_compute_url_map" "web_url_map" {
  name            = var.web_url_map_name
  default_service = google_compute_backend_service.loadbalancer.self_link
  depends_on      = [google_compute_backend_service.loadbalancer]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy
resource "google_compute_target_https_proxy" "webapp_proxy" {
  name    = var.webapp_proxy_name
  url_map = google_compute_url_map.web_url_map.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.ssl_certificates.self_link
  ]

  depends_on = [google_compute_managed_ssl_certificate.ssl_certificates, google_compute_url_map.web_url_map]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = var.forwarding_rule_name
  target                = google_compute_target_https_proxy.webapp_proxy.id
  port_range            = var.forwarding_rule_port_range
  ip_protocol           = var.forwarding_rule_ip_protocol
  load_balancing_scheme = var.forwarding_rule_load_balancing_scheme
  ip_address            = google_compute_global_address.default_forward_address.id

  depends_on = [google_compute_target_https_proxy.webapp_proxy, google_compute_global_address.default_forward_address]
}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set
resource "google_dns_record_set" "webapp_dns" {
  name         = var.webapp_domain_name
  type         = var.webapp_domain_type
  ttl          = var.webapp_domain_ttl
  managed_zone = var.webapp_domain_managed_zone

  rrdatas = [google_compute_global_address.default_forward_address.address]

  depends_on = [google_compute_global_address.default_forward_address, google_compute_region_instance_template.webapp_vm_instance, ]
}

