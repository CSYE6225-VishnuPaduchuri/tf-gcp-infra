provider "google" {
  credentials = file(var.gcp_credentials)
  project = var.gcp_project_id
  region = var.gcp_project_region
}

resource "google_compute_network" "vpc" {
  name = var.vpc_name
  auto_create_subnetworks = var.vpc_create_subnets_automatically
  routing_mode = var.routing_mode_for_vpc
  delete_default_routes_on_create = var.vpc_delete_default_routes_on_create
}