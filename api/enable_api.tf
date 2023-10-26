provider "google" {
    credentials = file("../SA_KEY.json")
    project = "exalted-kit"
    region =  "us-east1"   # default for resources
}



#resource "google_project_service" "service_usage" {
#  project = "exalted-kit"
#  service = "serviceusage.googleapis.com"
#}


#resource "google_project_service" "cloud_resource_manager" {
#  project = var.project_id
#  service = "cloudresourcemanager.googleapis.com"
#}



#resource "google_project_service" "compute_api" {
#  project = "exalted-kit"
#  service = "compute.googleapis.com"
#  depends_on = [google_project_service.service_usage]
#}

#resource "null_resource" "enable_service_usage" {
#  provisioner "local-exec" {
#    command = "gcloud auth activate-service-account --key-file=../SA_KEY.json && gcloud services enable serviceusage.googleapis.com --project=exalted-kit && gcloud services enable compute.googleapis.com --project=exalted-kit && gcloud auth revoke"
#    environment = {
#      GOOGLE_APPLICATION_CREDENTIALS = "../SA_KEY.json"
#    }
#  }
#}


