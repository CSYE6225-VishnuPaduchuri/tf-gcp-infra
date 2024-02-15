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
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_ip_cidr_range
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "db" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_ip_cidr_range
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_route" "webapp_subnet_route" {
  network          = google_compute_network.vpc.self_link
  name             = var.webapp_subnet_route_name
  dest_range       = var.webapp_subnet_route_dest_range
  next_hop_gateway = var.webapp_subnet_route_next_hop_gateway
  priority         = var.webapp_subnet_route_priority
}
