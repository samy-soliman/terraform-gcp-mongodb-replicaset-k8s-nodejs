module "network" {
    source = "./network"
    project_id = var.project_id
}

module "compute" {
    source = "./compute"
}
