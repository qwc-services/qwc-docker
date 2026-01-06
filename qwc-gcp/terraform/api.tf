resource "google_project_service" "secret" {
  project = var.project-name
  service = "secretmanager.googleapis.com"
  disable_dependent_services = false
}