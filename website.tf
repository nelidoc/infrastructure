resource "google_secret_manager_secret" "openai_key" {
  secret_id = "openai"
  replication {
    auto {}
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.website.location
  project  = google_cloud_run_v2_service.website.project
  service  = google_cloud_run_v2_service.website.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id  = google_secret_manager_secret.openai_key.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.openai_key]
}

resource "google_cloud_run_v2_service" "website" {
  name     = "website"
  location = "europe-west1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    volumes {
      name = "openai"
      secret {
        secret       = google_secret_manager_secret.openai_key.secret_id
        default_mode = 292 # 0444
      }
    }
    max_instance_request_concurrency = 3

    containers {
      name  = "website"
      image = "enriquelopp/website"
      ports {
        container_port = 8501
        # name           = "http"
      }
      #   volume_mounts {
      #     name       = "openai"
      #     mount_path = "/root/.streamlit/secrets.toml"
      #   }
      startup_probe {
        initial_delay_seconds = 11
        http_get {
        #   path = "/_stcore/health"
          port = 8501
        }
      }
      liveness_probe {
        http_get {
          port = 8501
          path = "/_stcore/health"
        }
      }
    }
  }
}
resource "google_cloud_run_domain_mapping" "website" {
  name     = "nelidoc.com"
  location = google_cloud_run_v2_service.website.location
  metadata {
    namespace = data.google_project.project.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.website.name
  }
}

resource "google_dns_record_set" "website_a" {
  managed_zone = google_dns_managed_zone.neli.name
  name         = "nelidoc.com."
  type         = "A"
  rrdatas      = [for record in google_cloud_run_domain_mapping.website.status[0].resource_records: record.rrdata if record.type == "A"]
  ttl          = 300
}

resource "google_dns_record_set" "website_aaaa" {
  managed_zone = google_dns_managed_zone.neli.name
  name         = "nelidoc.com."
  type         = "AAAA"
  rrdatas      =  [for record in google_cloud_run_domain_mapping.website.status[0].resource_records: record.rrdata if record.type == "AAAA"]
  ttl          = 300
}

