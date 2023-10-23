#!/bin/bash

# Remove Docker if already installed
sudo apt-get -y remove docker docker-engine docker.io containerd runc

# Update package lists
sudo apt-get -y update && sudo apt-get -y upgrade

# Install Docker dependencies
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Start Docker service
sudo service docker start

# Add the current user to the 'docker' group (to avoid using 'sudo' for Docker commands)
sudo usermod -aG docker $USER

echo "Docker installation completed!"
