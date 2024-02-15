# tf-gcp-infra

# Prerequisites

1. On the local machine, we have to create a .terraform folder
2. on the GCP console navigate to IAM -> Service Account
   1. Here we will see all the projects that have been created for the user
   2. Select the project and if its first time we are selecting project then we have to add a key to it
   3. Once we select the project, navigate to the keys tab and select the Add key drop down. Select the JSON option and a credentails file will be automatically downloaded (the content of this file is what is supposed to be under .terraform folder)
3. We can create differnt files to segregate the varibales and resource defintions
4. Create a maingcp.tf file and there we will define the provider, the VPC, subnets and also routes
5. create a variable file and define each variable along with a description and its type

# Setting up resources using terraform

Now that we have added the required files, we will now run certain commands

1. terraform init - This command is used to initialise the terraform configuration we have mentioned in the maingcp.tf file.

2. terraform fmt - This command is used to foramt the styling and indentation fo the terraform files. I feel this is a good practice to be implemented, as when we are working in a team, each of the team members might have differnt styling etc and having a single format makes it simpler.

3. terraform validate - This command checks if the syntax of the configuration is valid or not.

4. terraform apply - This command will makes changes described in the configuration

There are other commands that we will be running as well

1. terraform plan - This command will generate the plan that shows what will happen when we run the apply command

2. terraform destroy - This command will destroy all the resources we have mentioned in out configuration

# Verifying the changes on the GCP console

1. On the GCP homepage, select the hamburger menu and click on VPC network
2. Select the VPC that was created using the configuration
3. we can now view the subnets and routes that were added via the configuration

# List of APIs enabled in GCP

1. Compute Engine API
2. Cloud DNS API
3. Artifact Registry API
4. Cloud Build API
5. Cloud Functions API
6. Cloud Logging API
7. Cloud Monitoring API
8. Cloud OS Login API
9. Cloud Pub/Sub API
10. Cloud SQL Admin API
11. Container Registry API
12. Cloud Storage
13. Container Registry API
14. Google Cloud Storage JSON API
15. IAM Service Account Credentials API
16. Identity and Access Management (IAM) API
