module "network" {
    source = "./network"
    project_id = var.project_id
}

module "storage" {
    source = "./storage"
}

module "compute" {
    source = "./compute"
}
