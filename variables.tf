
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
