<h3> terraform apply --var-file=dev.tfvars</h3>
<h3> terraform destroy --var-file=dev.tfvars</h3>

<h3> 1- prepare the vm for the first time -> run init script </h3>
This step is automated the init script is in starter script for the vm</br>


<h3> 2- authenticate docker </h3>
# authenticate artifact registry in your host, replace region with yours</br>
# gcloud auth configure-docker us-east1-docker.pkg.dev</br>
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin  us-east1-docker.pkg.dev</br>

<h3> 3- authenticate kubernetes gke </h3>
# authenticate your cluster with gcp , replace name, cluster and project with your values</br>
gcloud container clusters get-credentials pgke-cluster --region us-central1 --project exalted-kit </br>

<h3> 4- get mongodb image and push to registry </h3>
# pull bitnami image, tag and push it to our gcp registry</br>
# note this is the name in our nodejs app for the db uri</br>
sudo docker pull docker.io/bitnami/mongodb:5.0
sudo docker tag docker.io/bitnami/mongodb:5.0 us-east1-docker.pkg.dev/exalted-kit/mongo-registry/bitnami:1
sudo docker push us-east1-docker.pkg.dev/exalted-kit/mongo-registry/bitnami:1

<h3> 4- get node app, build docker image and push to registry </h3>
# build the nodejs app docker image and push it
sudo docker build -t us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:1 .
sudo docker push  us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:1

<h3> 5- deploy app to gke </h3>
kubectl create -f k8s/ </br>
<h3> 6- test gke statefull-set </h3>
delete pods of mongo and test data is persistent </br>