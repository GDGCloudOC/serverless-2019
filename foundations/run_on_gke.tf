locals {
  run_on_gke_region = "us-west1"
}

data "google_compute_network" "demo" {
  project = "${module.serverless.project_id}"
  name    = "demo"
}

resource "google_compute_subnetwork" "run" {
  name          = "run-on-gke"
  project       = "${module.serverless.project_id}"
  network       = "${data.google_compute_network.demo.self_link}"
  region        = "${local.run_on_gke_region}"
  ip_cidr_range = "172.16.33.0/24"

  secondary_ip_range = [
    {
      range_name    = "run-on-gke-services"
      ip_cidr_range = "172.16.34.0/24"
    },
    {
      range_name    = "run-on-gke-pods"
      ip_cidr_range = "172.16.0.0/19"
    },
  ]
}

data "google_compute_zones" "run_on_gke" {
  project = "${module.serverless.project_id}"
  region  = "${local.run_on_gke_region}"
  status  = "UP"
}

resource "google_container_cluster" "run" {
  provider       = "google-beta"
  name           = "run-on-gke"
  project        = "${module.serverless.project_id}"
  description    = "Cloud Run on GKE cluster"
  zone           = "${element(data.google_compute_zones.run_on_gke.names, 0)}"
  node_locations = ["${slice(data.google_compute_zones.run_on_gke.names, 1, length(data.google_compute_zones.run_on_gke.names) - 1)}"]

  # This is per-zone
  initial_node_count = 1
  min_master_version = "1.12"

  enable_binary_authorization = false
  enable_kubernetes_alpha     = false
  enable_tpu                  = false
  enable_legacy_abac          = false
  logging_service             = "logging.googleapis.com/kubernetes"
  monitoring_service          = "monitoring.googleapis.com/kubernetes"

  # Disable basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Node configuration
  node_config {
    preemptible     = false
    machine_type    = "n1-standard-2"
    service_account = "${module.serverless.service_accounts["gke-cluster"]}"
    disk_size_gb    = "20"
    disk_type       = "pd-ssd"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  cluster_autoscaling {
    enabled = false
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "06:00"
    }
  }

  network    = "${data.google_compute_network.demo.name}"
  subnetwork = "${google_compute_subnetwork.run.name}"

  ip_allocation_policy {
    use_ip_aliases                = true
    services_secondary_range_name = "${google_compute_subnetwork.run.secondary_ip_range.0.range_name}"
    cluster_secondary_range_name  = "${google_compute_subnetwork.run.secondary_ip_range.1.range_name}"
  }

  # Enable add-ons
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = true
    }

    istio_config {
      disabled = false
    }

    cloudrun_config {
      disabled = false
    }
  }

  depends_on = ["google_compute_subnetwork.run"]

  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }
}
