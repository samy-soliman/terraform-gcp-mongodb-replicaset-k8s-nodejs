resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "gke"
}

resource "google_project_iam_member" "artifact_admin_iam_gke" {
  project = "exalted-kit"
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}


resource "google_container_cluster" "gke_primary_cluster" {
    
    name = "pgke-cluster"
    location = "us-central1"
    network = "mongo-vpc"
    subnetwork = "workload-subnetwork"
    networking_mode = "VPC_NATIVE"
    
    private_cluster_config {
        enable_private_endpoint = true
        enable_private_nodes = true

        # ip address for the control plane
        master_ipv4_cidr_block  = "172.16.0.0/28"

        # Add the enable-master-global-access flag to create a private cluster
        # with global access to the control plane's private endpoint enabled:
        master_global_access_config {
          enabled = true
        }
    }
    
    ip_allocation_policy {
        cluster_ipv4_cidr_block = "10.11.0.0/21"
        services_ipv4_cidr_block = "10.12.0.0/21"
    }


    master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/24"
      display_name = "management_subnet"
    }
  }
    
    # We can't create a cluster with no node pool defined, but we want to only use
    # separately managed node pools. So we create the smallest possible default
    # node pool and immediately delete it.
    remove_default_node_pool = true
    initial_node_count = 1

    deletion_protection = false
    #depends_on = [google_compute_subnetwork.workload_subnet]
}


resource "google_container_node_pool" "mongo_node_pool" {
  name       = "mongo-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.gke_primary_cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    // Specify the disk size here
    disk_size_gb = 40

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_service_account.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [google_container_cluster.gke_primary_cluster]
}