
# How we define variables in terraform is referenced from 
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-variables

variable "gcp_credentials" {
  description = "GCP credentials for the project"
  type        = string
}

variable "gcp_project_id" {
  description = "The project id where the resources will be created"
  type        = string
}

variable "gcp_project_region" {
  description = "GCP project region"
  type        = string
}

variable "vpc_name" {
  description = "VCP Name"
  type        = string
}

variable "vpc_create_subnets_automatically" {
  description = "This indicates if subnets should be created automatically or not"
  type        = bool
}

variable "routing_mode_for_vpc" {
  description = "Routing mode for the VPC"
  type        = string
}

variable "vpc_delete_default_routes_on_create" {
  description = "Delete default routes on create"
  type        = bool
}

variable "webapp_subnet_name" {
  description = "The name of the webapp subnet"
  type        = string
}

variable "webapp_subnet_ip_cidr_range" {
  description = "The IP CIDR range of the webapp subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "The name of the DB subnet"
  type        = string
}

variable "db_subnet_ip_cidr_range" {
  description = "The IP CIDR range of the DB subnet"
  type        = string
}

variable "webapp_subnet_route_name" {
  description = "The name given to the webapp subnet route"
  type        = string
}

variable "webapp_subnet_route_dest_range" {
  description = "The destination range for the webapp subnet route"
  type        = string
}

variable "webapp_subnet_route_next_hop_gateway" {
  description = "The next hop gateway for the webapp subnet route"
  type        = string
}

variable "webapp_subnet_route_priority" {
  description = "Delete default routes on create"
  type        = number
}

variable "instance_machine_type" {
  description = "The machine type for the instance"
  type        = string
}

variable "instance_zone" {
  description = "The zone where the instance will be created"
  type        = string
}

variable "instance_image_from_packer" {
  description = "The image genereated from packer that will be used in the instance"
  type        = string
}

variable "gcp_firwall_name" {
  description = "The name given to the firewall"
  type        = string
}

variable "gcp_firewall_ports" {
  description = "The firewall ports"
  type        = list(string)
}

variable "gcp_firewall_source_ranges" {
  description = "The firewall source ranges"
  type        = list(string)
}

variable "gcp_firewall_allowed_protocol" {
  description = "The protocols allowed via the firewall"
  type        = string
}

variable "instance_name_of_webapp" {
  description = "The name given to the GCP VM"
  type        = string
}

variable "instance_image_type" {
  description = "The type of the image"
  type        = string
}

variable "instance_image_disk_size" {
  description = "The size of the image disk size"
  type        = number
}

// Priority range starts from 0, and the less the number the higher the priority
variable "gcp_firewall_priority" {
  description = "The priority of the firewall"
  type        = number
}


variable "gcp_deny_firewall_name" {
  description = "The name given to the deny firewall"
  type        = string
}

variable "gcp_deny_firewall_ports" {
  description = "The deny firewall ports"
  type        = list(string)
}

variable "gcp_deny_firewall_source_ranges" {
  description = "The deny firewall source ranges"
  type        = list(string)
}

variable "gcp_deny_firewall_allowed_protocol" {
  description = "The protocols denied by the firewall"
  type        = string
}

variable "instance_boot_disk_auto_delete" {
  description = "This indicates if the boot disk should be deleted when we run terrafom destroy"
  type        = bool
}

variable "vm_firewall_target_tags" {
  description = "The target tags for the VM firewall"
  type        = list(string)
}

variable "subnet_private_ip_google_access" {
  description = "This indicates if the VPC is private and can communicate with google services through private IP"
  type        = bool
}

variable "global_address_name" {
  description = "The name given to the global address"
  type        = string
}

variable "global_address_type" {
  description = "The type of the global address"
  type        = string
}

variable "global_address_purpose" {
  description = "The purpose of the global address"
  type        = string
}

variable "global_address_prefix_length" {
  description = "The prefix length of the global address"
  type        = number
}

variable "google_service_networking_connection_service_name" {
  description = "The name of the google service networking connection"
  type        = string
}

variable "google_service_networking_connection_deletion_policy" {
  description = "The deletion policy for the google service networking connection"
  type        = string
}

variable "random_id_suffix_for_db_instance_byte_length" {
  description = "The byte length for the random id suffix for the DB instance"
  type        = number
}

variable "google_sql_database_instance_database_version" {
  description = "The database version for the DB type we select such as POSTGRES_15"
  type        = string
}

variable "google_sql_database_instance_deletion_policy" {
  description = "The deletion policy set for the DB instance"
  type        = bool
}

variable "google_sql_database_instance_tier" {
  description = "The tier set for the DB instance"
  type        = string
}

variable "google_sql_database_instance_availability_type" {
  description = "The availability type set for the DB instance"
  type        = string
}

variable "google_sql_database_instance_disk_type" {
  description = "The disk type used for the DB instance"
  type        = string
}

variable "google_sql_database_instance_disk_size" {
  description = "The disk size used for the DB instance"
  type        = number
}

variable "google_sql_database_instance_ipv4_enabled" {
  description = "This tells if ipv4 is enabled or not for the DB instance"
  type        = bool
}

variable "google_sql_database_instance_private_path_for_GCP_services" {
  description = "This tells if private path for GCP services is enabled or not for the DB instance"
  type        = bool
}

variable "google_sql_database_name" {
  description = "The name set for the Database"
  type        = string
}

variable "random_password_length" {
  description = "The length of the random password that we will use for the DB user"
  type        = number
}

variable "random_password_override_special" {
  description = "The special characters that we will use for the random password"
  type        = string
}

variable "random_password_special" {
  description = "This tells if special characters are allowed in the random password"
  type        = bool
}

variable "google_sql_user_name" {
  description = "The name of the user for the DB"
  type        = string
}

variable "webapp_domain_name" {
  description = "The domain name that we will use for webapp"
  type        = string
}

variable "webapp_domain_type" {
  description = "The type of the domain"
  type        = string
}

variable "webapp_domain_ttl" {
  description = "The time to live for the domain"
  type        = number
}

variable "webapp_domain_managed_zone" {
  description = "The managed zone for the domain"
  type        = string
}

variable "service_account_id" {
  description = "value of the service account id"
  type        = string
}

variable "service_account_display_name" {
  description = "The display name of the service account"
  type        = string
}

variable "service_account_create_ignore_already_exists" {
  description = "The boolean value to ignore already exists"
  type        = bool
}

variable "logging_service_role" {
  description = "The role for the logging service"
  type        = string
}

variable "monitoring_service_role" {
  description = "The role for the monitoring service"
  type        = string
}

variable "service_account_scopes" {
  description = "The scopes for the service account"
  type        = list(string)
}

variable "pubsub_publisher_role" {
  description = "The role for the pubsub publisher"
  type        = string
}

variable "token_creator_role" {
  description = "The role for the token creator"
  type        = string
}

variable "cloud_functions_developer_role" {
  description = "The role for the cloud functions developer"
  type        = string
}

variable "cloud_runner_invoker_role" {
  description = "The role for the cloud runner invoker"
  type        = string
}

variable "serverless_vpc_access" {
  description = "Serverless VPC Access values"
  type = object({
    name           = string
    ip_cidr_range  = string
    machine_type   = string
    min_instances  = number
    max_instances  = number
    max_throughput = number
  })
}

variable "pubsub_values" {
  description = "Variables for PubSub"
  type = object({
    schema_name             = string
    schema_type             = string
    schema_definition       = string
    topic_name              = string
    topic_message_retention = string
    topic_settings_encoding = string
    subscription_name       = string
  })
}

variable "mail_gun_api_key" {
  description = "Mailgun API key"
  type        = string
}

variable "serverless_cloud_function" {
  description = "Cloud Function variables"
  type = object({
    name                     = string
    description              = string
    runtime                  = string
    entry_point              = string
    bucket_source            = string
    object_source            = string
    timeout                  = number
    memory                   = string
    max_instance_concurrency = number

    min_instance_count             = number
    max_instance_count             = number
    available_cpu                  = number
    ingress_settings               = string
    vpc_connector_egress_settings  = string
    all_traffic_on_latest_revision = bool
    event_type                     = string
    retry_policy                   = string
  })
}

variable "instance_template_name" {
  description = "The name of the instance template"
  type        = string
}

variable "instance_template_machine_type" {
  description = "The machine type for the instance template"
  type        = string
}

variable "instance_template_can_ip_forward" {
  description = "This indicates if the instance can forward IP packets"
  type        = bool
}

variable "instance_template_name_auto_delete" {
  description = "This indicates if the instance should be deleted when we run terraform destroy"
  type        = bool
}

variable "instance_template_name_boot" {
  description = "value of the boot disk"
  type        = bool
}

variable "instance_template_affinity_type" {
  description = "The type of reservation from which this instance can consume resources"
  type        = string
}

variable "instance_template_scheduling_preemptible" {
  description = "Allows instance to be preempted"
  type        = bool
}

variable "instance_template_scheduling_automatic_restart" {
  description = "Specifies whether the instance should be automatically restarted if it is terminated by Compute Engine"
  type        = bool
}

variable "loadbalancer_firewall_name" {
  description = "The name of the firewall for the load balancer"
  type        = string
}

variable "loadbalancer_firewall_protocol" {
  description = "The protocol for the load balancer firewall"
  type        = string
}

variable "loadbalancer_firewall_ports" {
  description = "The ports for the load balancer firewall"
  type        = list(string)
}

variable "loadbalancer_firewall_source_ranges" {
  description = "The source ranges for the load balancer firewall"
  type        = list(string)
}

variable "loadbalancer_firewall_priority" {
  description = "The priority for the load balancer firewall"
  type        = number
}

variable "ssl_certificate_name" {
  description = "The name of the SSL certificate"
  type        = string
}

variable "default_forward_address_name" {
  description = "The name of the default forward address"
  type        = string
}

variable "instance_health_check_name" {
  description = "The name of the instance health check"
  type        = string
}

variable "instance_health_check_interval_sec" {
  description = "The interval in seconds for the instance health check"
  type        = number
}

variable "instance_health_check_timeout_sec" {
  description = "The timeout in seconds for the instance health check"
  type        = number
}

variable "instance_health_check_healthy_threshold" {
  description = "The healthy threshold for the instance health check"
  type        = number
}

variable "instance_health_check_unhealthy_threshold" {
  description = "The unhealthy threshold for the instance health check"
  type        = number
}

variable "instance_health_check_port_name" {
  description = "The port name for the instance health check"
  type        = string
}

variable "instance_health_check_request_path" {
  description = "The request path for the instance health check"
  type        = string
}

variable "instance_health_check_port" {
  description = "The port for the instance health check"
  type        = number
}

variable "instance_group_manager_name" {
  description = "The name of the instance group manager"
  type        = string
}

variable "instance_group_manager_base_instance_name" {
  description = "value of the base instance name"
  type        = string
}

variable "instance_group_manager_description" {
  description = "The description of the instance group manager"
  type        = string
}

variable "instance_group_manager_distribution_policy_zones" {
  description = "The zones for the instance group manager"
  type        = list(string)
}

variable "instance_group_manager_distribution_policy_target_shape" {
  description = "The target shape for the instance group manager"
  type        = string
}

variable "instance_group_manager_port_name" {
  description = "The port name for the instance group manager"
  type        = string
}

variable "instance_group_manager_port" {
  description = "The port for the instance group manager"
  type        = number
}

variable "instance_group_manager_port_healing_initial_delay" {
  description = "The initial delay for the port healing"
  type        = number
}

variable "autoscaler_name" {
  description = "The name of the autoscaler"
  type        = string
}

variable "autoscaler_max_replicas" {
  description = "The maximum number of replicas for the autoscaler"
  type        = number
}

variable "autoscaler_min_replicas" {
  description = "The minimum number of replicas for the autoscaler"
  type        = number
}

variable "autoscaler_cooldown_period" {
  description = "The cooldown period for the autoscaler"
  type        = number
}

variable "autoscaler_cpu_target" {
  description = "The CPU target for the autoscaler"
  type        = number
}

variable "loadbalancer_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "loadbalancer_enable_cdn" {
  description = "This indicates if the CDN should be enabled for the load balancer"
  type        = bool
}

variable "loadbalancer_balancing_mode" {
  description = "The balancing mode for the load balancer"
  type        = string
}

variable "loadbalancer_capacity_scaler" {
  description = "The capacity scaler for the load balancer"
  type        = number
}

variable "loadbalancer_protocol" {
  description = "The protocol for the load balancer"
  type        = string
}

variable "loadbalancer_port_name" {
  description = "The port name for the load balancer"
  type        = string
}

variable "loadbalancer_load_balancing_scheme" {
  description = "The load balancing scheme for the load balancer"
  type        = string
}

variable "loadbalancer_timeout_sec" {
  description = "The timeout in seconds for the load balancer"
  type        = number
}

variable "web_url_map_name" {
  description = "The name of the web url map"
  type        = string
}

variable "webapp_proxy_name" {
  description = "The name of the webapp proxy"
  type        = string
}