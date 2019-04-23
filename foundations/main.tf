# Creates a project for serverless demonstrations

# Use latest 2.x version of Google provider with Atum credentials
provider "google" {
  version     = "~> 2.0"
  credentials = "${file("${path.module}/atum-terraform-credentials.json")}"
}

# Use latest 2.x version of Google beta provider with Atum credentials
provider "google-beta" {
  version     = "~> 2.0"
  credentials = "${file("${path.module}/atum-terraform-credentials.json")}"
}

# Share Terraform state in atum bucket
terraform {
  backend "gcs" {
    bucket = "atum-the-creator"
    prefix = "terraform/demos/serverless"
  }
}

# Use Neudesic's project factory to create a project
module "serverless" {
  source                = "github.com/NeudesicGCP/terraform-project-factory"
  project_id            = "serverless"
  display_name          = "Serverless demos on GCP"
  folder_id             = "29267072323"
  terraform_credentials = "${path.module}/atum-terraform-credentials.json"
  org_domain_name       = "neudesic.com"
  org_billing_name      = "neugcp"

  enable_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "containeranalysis.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
  ]

  service_account_ids = [
    "gke-cluster",
  ]

  iam_assignments = [
    "group:gcpdemos@neudesic.com=roles/container.admin",
    "gke-cluster=roles/storage.objectViewer",
    "gke-cluster=roles/logging.logWriter",
    "gke-cluster=roles/monitoring.viewer",
    "gke-cluster=roles/monitoring.metricWriter",
  ]

  # Create a network, but don't define the subnets yet
  networks = [
    "demo",
  ]
}
