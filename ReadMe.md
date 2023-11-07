# ![Multi-Zone Deployment of a Stateless Node.js App with a Stateful MongoDB Replicaset on GCP using Terraform and Kubernetes](image.png)

![Architecture](/Images/Architecture.png)

In this project I will deploy a simple Node.js web application **(stateless)** that interacts with a highly available MongoDB **(stateful)** replicated across **3 zones** and consisting of 1 primary and 2 secondaries.

Notes:
- Only the **Management VM (private)** will have access to internet through the **NAT**.
- The **GKE cluster (private)** will NOT have access to the internet.
- The **Management VM** will be used to manage the **GKE cluster** and **build/push** images to the **Artifact Registry**.
- All deployed images must be stored in Artifact Registry.

## Explaining The Project Architecture:
1. The **compute** folder contains the terraform files to create.
   - management vm compute instance
   - management vm service account
   - google kubernetes engine (GKE)
   - GKE service account
2. The **network** folder containes the terraform files to create.
   - VPC for our application.
   - 2 subnets one for managemnt resources, the other for workloud resources.
   - nat gateway for our management vm.
   - firewall rules to allow ssh port to our private vm through IAP IP ranges.
3. The **storage** folder contains terraform code to create.
   - Artifact registry, wil be used to host our mongo and nodejs docker images.
4. The **api** folder contains
   - terraform files to enable gcp api's, sadly that did not work so i had to do it manually.
   - it seems like an issue in gcp between the time it takes to enable each service that depend on one another.
5. The **documents-k8s-nodejs-scripts** file contains
   - archive folder for other implementains for mongo replicaset.
   - k8s folder for our mongo replicaSet implementation used in our project it leverages bitnami docker image.
   - nodejs folder for our nodeJS app files, dockerfile to build the app and kubernetes file for our app deployment.
6. The **troubleshoot** folder contains
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
5. Alter **dev.tfvars** file with your custom needs, its **mandatory** to change the project_id with your own.
6. Initialize terraform

```Shell
    terraform init
```

7. Deploy resources to GCP by applting our terraform code

```Shell
    terraform apply --var-file=dev.tfvars
```

8. Once you get the success message for deploying the resources, we can then start our app deployment.

9. To start deploying apps, we start by ssh to our private vm instance, replace your project id and vm zone.

```Shell
    gcloud compute ssh --zone "vm-zone" "management-vm" --tunnel-through-iap --project "your-project-id"
```

10. Now the **init.sh** script in our project root directory is resposible to initialize our vm with required tools like git, docker, kubectl and gcp gke auth plugins.

11. Now the following steps can be merged into a script to do it automatically but i will do it manually to clarify the steps for you. 
12. Add nodeJS files and k8s files into a different repo and clone them into your vm.
13. generate a gcp auth token and feed it into docker command to authenticate docker to use our artifact registry on gcp , note that this token it not permenant, replace the region with your artifact registry region.

```Shell
    gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin  your_region-docker.pkg.dev
```

14. Add credentials for GKE on private vm to enable kubectl managing our cluster, replace your cluster_name, project_id and cluster_region.

```Shell
    gcloud container clusters get-credentials cluster_name --region cluster_region --project project_id
```

15. Pull the bitnami docker image into our vm, tag it with artifact registry uri then push it to the registry,
    do not foreget to replace your values

```Shell
    sudo docker pull docker.io/bitnami/mongodb:5.0
    sudo docker tag docker.io/bitnami/mongodb:5.0 YourArtifactRegion-docker.pkg.dev/YourProjectID/YourRegistryName/bitnami:1
    sudo docker push YourArtifactRegion-docker.pkg.dev/YourProjectID/YourRegistryName/bitnami:1 
```

16. Go to the node app folder and build its image with proper tag then push it to registry.

```Shell
    sudo docker build -t YourArtifactRegion-docker.pkg.dev/YourProjectID/YourRegistryName/nodejs:1 .
    sudo docker push  YourArtifactRegion-docker.pkg.dev/YourProjectID/YourRegistryName/nodejs:1 
```

17. Not its time to action by deploying our mongo replicaset to GKE, do not forget to edit the kubernetes manifest for statefullset and arbiter with you mongo image tagged name.

```Shell
    kubectl create -f k8s/
```

18. Now That out database is ready we can start deploying our nodeJS app ro GKE, do not forget to edit the kubernetes manifest for your nodejs image tagged name.

```Shell
    kubectl create -f nodejs-deployment.yml
```

19. That should be it now lets see a quick run in action.
20. After it do not forget to clean your resources with

```Shell
    terraform destroy --var-file=dev.tfvars
```

## Quick Run,  YAY!
1. I have steps 1 to 6 covered to i will jump with deploying the app.

2. Confirm our infrastructure is created inside gcp console

3. Now i am going to ssh into my private vm.

4. Now to clone the mongo and nodejs files, i have them in a diffrent repo so you can use it but do not forget to alter the images tags.

```Shell
    git clone https://github.com/samy-soliman/nodejs-k8s.git
```
5. authenticate docker

```Shell
    gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin  us-east1-docker.pkg.dev
```

6. Add GKE credentials, we can test it by running a simble listing of our nodes.
```Shell
    gcloud container clusters get-credentials pgke-cluster --region us-central1 --project exalted-kit
```

7. Get the bitnami image, tag it and push it to out resgistry.

```Shell
    sudo docker pull docker.io/bitnami/mongodb:5.0
    sudo docker tag docker.io/bitnami/mongodb:5.0 us-east1-docker.pkg.dev/exalted-kit/mongo-registry/bitnami:1
    sudo docker push us-east1-docker.pkg.dev/exalted-kit/mongo-registry/bitnami:1
```


8. Now lets build our nodejs app and push it our registry.

```Shell
    sudo docker build -t us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:1 .
    sudo docker push  us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:1
```

9. Now lets deploy our mongo replicaSet

```Shell
    kubectl create -f k8s/
```

10. now its the final moment we are waiting deploying our nodeJS app, note that we have a LoadBalancer service to test our app so what are we waiting for!!

```Shell
    kubectl create -f nodejs-deployment.yml
```

11. 