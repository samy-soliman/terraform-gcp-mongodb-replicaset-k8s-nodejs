# terraform apply --var-file=dev.tfvars
# terraform destroy --var-file=dev.tfvars

<h3> 1- prepare the vm for the first time -> run init script </h3>
chmod 400 init.sh</br>
bash init.sh</br>

<h3> 2- authenticate docker </h3>
# authenticate artifact registry in your host, replace region with yours</br>
# gcloud auth configure-docker us-east1-docker.pkg.dev</br>
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken</br> --password-stdin  us-east1-docker.pkg.dev</br>

<h3> 3- authenticate kubernetes gke </h3>
# authenticate your cluster with gcp , replace name, cluster and project with your values</br>
gcloud container clusters get-credentials gke-cluster --region us-central1 --project exalted-kit </br>

<h3> 4- get mongodb image and push to registry </h3>
# pull bitnami image, tag and push it to our gcp registry</br>
# note this is the name in our nodejs app for the db uri</br>
sudo docker pull docker.io/bitnami/mongodb:4.4.4</br>
sudo docker tag docker.io/bitnami/mongodb:4.4.4 us-east1-docker.pkg.dev/exalted-kit/mongo-registry/bitnami:v1</br>

<h3> 4- get node app, build docker image and push to registry </h3>
# build the nodejs app docker image and push it </br>
sudo docker build -t us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:v1 . </br>
sudo docker push  us-east1-docker.pkg.dev/exalted-kit/mongo-registry/nodejs:v1 </br>

<h3> 5- deploy app to gke </h3>

<h3> 6- test gke statefull-set </h3>
