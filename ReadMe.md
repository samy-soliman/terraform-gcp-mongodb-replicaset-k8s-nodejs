# ![Multi-Zone Deployment of a Stateless Node.js App with a Stateful MongoDB Replicaset on GCP using Terraform and Kubernetes](image.png)

![Architecture](/Images/Architecture.png)

In this project I will deploy a simple Node.js web application **(stateless)** that interacts with a highly available MongoDB **(stateful)** replicated across **3 zones** and consisting of 1 primary and 2 secondaries.

Notes:
- Only the **Management VM (private)** will have access to internet through the **NAT**.
- The **GKE cluster (private)** will NOT have access to the internet.
- The **Management VM** will be used to manage the **GKE cluster** and **build/push** images to the **Artifact Registry**.
- All deployed images must be stored in Artifact Registry.

## Explaining The Project Architecture:
1. The compute folder contains the terraform files to create.
   - management vm compute instance
   - management vm service account
   - google kubernetes engine (GKE)
   - GKE service account
2. The network folder containes the terraform files to create.
   - VPC for our application.
   - 2 subnets one for managemnt resources, the other for workloud resources.
   - nat gateway for our management vm.
   - firewall rules to allow ssh port to our private vm through IAP IP ranges.
3. The storage folder contains terraform code to create.
   - Artifact registry, wil be used to host our mongo and nodejs docker images.
4. The api folder contains
   - terraform files to enable gcp api's, sadly that did not work so i had to do it manually.
   - it seems like an issue in gcp between the time it takes to enable each service that depend on one another.
5. The documents-k8s-nodejs-scripts file contains
   - archive folder for other implementains for mongo replicaset.
   - k8s folder for our mongo replicaSet implementation used in our project it leverages bitnami docker image.
   - nodejs folder for our nodeJS app files, dockerfile to build the app and kubernetes file for our app deployment.
6. The troubleshoot folder contains
   - custom docker image with mongo client installed to test our mongo pods with if we have issue
   - custom docker file of mongo to use to build mongo replicaSet manually without using bitnami custom image.

## How To Get the Project Working
1. First clone the project files to your computer.
2. Create a GCP account and create a project and enable required services api's.
   - serviceusage.googleapis.com.
   - cloudresourcemanager.googleapis.com.
   - compute.googleapis.com.
   - artifact registry api.
   - kubernetes container api.
3. Create a service account for terraform to authenticate access to GCP, limit the permisstions as your need.
4. Download the service account and put it in your project root folder name it **SA_KEY.json**.
5. Alter **dev.tfvars** file with your custom needs, its mandatory to change the project_id with your own.
6. Initialize terraform

```Shell
    terraform init
```

7. A
