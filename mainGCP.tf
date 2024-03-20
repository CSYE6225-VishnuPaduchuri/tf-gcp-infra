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
  depends_on          = [google_service_networking_connection.private_connection_for_vpc]

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

# Reference from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "service_account" {
  account_id                   = var.service_account_id
  display_name                 = var.service_account_display_name
  create_ignore_already_exists = var.service_account_create_ignore_already_exists
}
resource "google_compute_instance" "webapp_vm_instance" {
  name         = var.instance_name_of_webapp
  machine_type = var.instance_machine_type
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = var.instance_image_from_packer
      type  = var.instance_image_type
      size  = var.instance_image_disk_size
    }
    auto_delete = var.instance_boot_disk_auto_delete
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {}
  }

  tags       = var.vm_firewall_target_tags
  depends_on = [google_compute_subnetwork.webapp, google_compute_firewall.webapp_firewall, google_compute_firewall.webapp_deny_firewall, google_sql_database_instance.postgres_db, google_sql_user.users]

  # In the startup script, i am adding check to see if ENV file path exists or not
  # If it doesnt no exists, then creating the env file and adding the environment variables
  # If file exists, then im updating the environment variables to the latest values
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

if [ -f "$ENV_FILE"  ]; then
    echo "Env file exists."
    sudo sed -i "s/^SERVER_PORT=.*/SERVER_PORT=$SERVER_PORT/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_NAME=.*/DATABASE_NAME=$DATABASE_NAME/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_USER_NAME=.*/DATABASE_USER_NAME=$DATABASE_USER_NAME/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$DATABASE_PASSWORD/" "$ENV_FILE"
    sudo sed -i "s/^DATABASE_HOST_URL=.*/DATABASE_HOST_URL=$DATABASE_HOST_URL/" "$ENV_FILE"
else
    echo "File does not exist."
    sudo sh -c "echo 'SERVER_PORT=$SERVER_PORT' > $ENV_FILE"
    sudo sh -c "echo 'DATABASE_NAME=$DATABASE_NAME' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_USER_NAME=$DATABASE_USER_NAME' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_PASSWORD=$DATABASE_PASSWORD' >> $ENV_FILE"
    sudo sh -c "echo 'DATABASE_HOST_URL=$DATABASE_HOST_URL' >> $ENV_FILE"
fi

sudo systemctl daemon-reload
sudo systemctl stop webapp
sudo systemctl start webapp

echo "Test=Working" >> /tmp/.testEnv

EOT
  }

}

# Reference taken from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set
resource "google_dns_record_set" "webapp_dns" {
  name         = var.webapp_domain_name
  type         = var.webapp_domain_type
  ttl          = var.webapp_domain_ttl
  managed_zone = var.webapp_domain_managed_zone

  rrdatas = [google_compute_instance.webapp_vm_instance.network_interface[0].access_config[0].nat_ip]
}

