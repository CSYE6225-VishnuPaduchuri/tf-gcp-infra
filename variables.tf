
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
