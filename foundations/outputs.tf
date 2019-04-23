data "google_container_registry_repository" "serverless" {
  project = "${module.serverless.project_id}"
  region  = "us"
}

output "project_id" {
  value = "${module.serverless.project_id}"
}

output "repo_url" {
  value = "${data.google_container_registry_repository.serverless.repository_url}"
}
