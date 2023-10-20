resource "google_service_account" "compute_instance_service_account" {
  account_id   = "compute-instance"
  display_name = "compute instance"
}

resource "google_project_iam_member" "artifact-admin-iam" {
  project = "exalted-kit"
  role  = "roles/artifactregistry.admin"
  member = "serviceAccount:${google_service_account.compute_instance_service_account.email}"
}


resource "google_compute_instance" "management_vm" {
  name         = "management-vm"
  machine_type = "n2-standard-2"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = "management-subnetwork"
    #access_config {// Ephemeral public IP}
  }

  service_account {
    email  = google_service_account.compute_instance_service_account.email
    scopes = ["cloud-platform"]
  }
}