resource "google_secret_manager_secret" "pgpass-qgis-cluster" {
  project = var.project-name
  secret_id = "pgpass-qgis-cluster"

  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "pgpass-qgis-cluster-version" {
  depends_on = [random_password.pgpass-qgis-cluster]
  secret = google_secret_manager_secret.pgpass-qgis-cluster.id
  secret_data = var.postgres-password
}