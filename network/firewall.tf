resource "google_compute_firewall" "iap_firewall" {
  name    = "iap-allow"
  network = "mongo-vpc" # Change to the appropriate network name if needed

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"] # Add more ports as needed
  }

  source_ranges = ["35.235.240.0/20"]

}



