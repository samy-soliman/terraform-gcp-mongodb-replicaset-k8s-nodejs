resource "google_service_account" "compute_instance_service_account" {
  account_id   = "compute-instance"
  display_name = "compute instance"
}

resource "google_project_iam_member" "artifact_admin_iam_vm" {
  project = "exalted-kit"
  role  = "roles/artifactregistry.admin"
  member = "serviceAccount:${google_service_account.compute_instance_service_account.email}"
}

resource "google_project_iam_member" "container_admin_iam_service_account" {
  project = "exalted-kit"
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.compute_instance_service_account.email}"
}


resource "google_compute_instance" "management_vm" {
  name         = "management-vm"
  machine_type = "n2-standard-2"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"    #"ubuntu-os-cloud/ubuntu-2004-lts"
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

  #depends_on = [google_compute_subnetwork.management_subnet]
}