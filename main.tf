locals {
  gcp_permissions = jsondecode(file("${path.module}/gcp_permissions.json"))
  orca_production_project_number = "788120191304"
}

resource "google_project_service" "service" {
  count   = length(local.gcp_permissions.api_services)
  project = var.service_project_id
  service = local.gcp_permissions.api_services[count.index]
}

resource "google_project_iam_custom_role" "orca-custom-role" {
  role_id      = "orca_security_in_account_side_scanner_role"
  title        = "In Account Orca Security Side Scanner Role"
  permissions  = concat(local.gcp_permissions.base, local.gcp_permissions.inaccount_extras)
  project      = var.service_project_id
}

resource "google_service_account" "orca" {
  account_id   = "orcasecurity-side-scanner"
  project      = var.service_project_id
  display_name = "Orca Security Side Scanning Service Account"
}

resource "google_project_iam_binding" "service-project-binding-1" {
  project = var.service_project_id
  role    = "roles/viewer"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "service-project-binding-2" {
  project = var.service_project_id
  role    = "projects/${var.service_project_id}/roles/${google_project_iam_custom_role.orca-custom-role.role_id}"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "service-project-binding-3" {
  project = var.service_project_id
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_service_account_key" "orca" {
  service_account_id = google_service_account.orca.name
}

resource "local_file" "orca" {
    content  = base64decode(google_service_account_key.orca.private_key)
    filename = "${path.module}/service_project_orca.json"
}

resource "google_project_service" "target" {
  count   = length(local.gcp_permissions.api_services)
  project = var.target_project_id
  service = local.gcp_permissions.api_services[count.index]
}

resource "google_project_iam_binding" "target-project-binding-1" {
  project = var.target_project_id
  role    = "roles/viewer"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "target-project-binding-2" {
  project = var.target_project_id
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "target-project-binding-3" {
  project = var.target_project_id
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "target-project-binding-4" {
  project = var.target_project_id
  role    = "roles/iam.securityReviewer"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

resource "google_project_iam_binding" "target-project-binding-5" {
  project = var.target_project_id
  role    = "projects/${var.target_project_id}/roles/${google_project_iam_custom_role.orca-custom-role.role_id}"
  members = [
    "serviceAccount:${google_service_account.orca.email}",
  ]
}

