
# How we define variables in terraform is referenced from 
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-variables

variable "gcp_credentials" {
    description = "GCP credentials for the project"
    type=string
}

variable "gcp_project_id" {
    description="The project id where the resources will be created"
    type=string
}

variable "gcp_project_region" {
    description="GCP project region"
    type=string
}

variable "vpc_name" {
    description="VCP Name"
    type=string
}

variable "vpc_create_subnets_automatically" {
    description="This indicates if subnets should be created automatically or not"
    type=bool
}

variable "routing_mode_for_vpc" {
    description="Routing mode for the VPC"
    type=string
}

variable "vpc_delete_default_routes_on_create" {
    description="Delete default routes on create"
    type=bool
}

variable "webapp_subnet_name"{
    description="The name of the webapp subnet"
    type=string
}

variable "webapp_subnet_ip_cidr_range" {
    description="The IP CIDR range of the webapp subnet"
    type=string
}

variable "db_subnet_name"{
    description="The name of the DB subnet"
    type=string
}

variable "db_subnet_ip_cidr_range" {
    description="The IP CIDR range of the DB subnet"
    type=string
}

variable "webapp_subnet_route_name" {
    description="The name given to the webapp subnet route"
    type=string
}

variable "webapp_subnet_route_dest_range" {
    description="The destination range for the webapp subnet route"
    type=string
}

variable "webapp_subnet_route_next_hop_gateway" {
    description="The next hop gateway for the webapp subnet route"
    type=string
}

variable "webapp_subnet_route_priority" {
    description="Delete default routes on create"
    type=number
}
