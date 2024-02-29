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
}

resource "google_compute_subnetwork" "db" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_ip_cidr_range
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = var.subnet_private_ip_google_access
}

resource "google_compute_route" "webapp_subnet_route" {
  network          = google_compute_network.vpc.self_link
  name             = var.webapp_subnet_route_name
  dest_range       = var.webapp_subnet_route_dest_range
  next_hop_gateway = var.webapp_subnet_route_next_hop_gateway
  priority         = var.webapp_subnet_route_priority
}

# Refrence taken from https://medium.com/google-cloud/terraform-on-google-cloud-v1-2-deploying-postgresql-with-github-actions-e7009cb04d22
resource "google_compute_global_address" "app_global_address" {
  name          = var.global_address_name
  address_type  = var.global_address_type
  purpose       = var.global_address_purpose
  network       = google_compute_network.vpc.self_link
  prefix_length = var.global_address_prefix_length
  depends_on = [google_compute_network.vpc]
}

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
  depends_on = [google_compute_subnetwork.webapp, google_compute_firewall.webapp_firewall]

}
