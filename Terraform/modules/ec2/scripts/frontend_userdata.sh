#!/bin/bash

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# In the "Frontend" EC2 (React), clone your source code repository
echo " Cloning Repository ..."
git clone https://github.com/uzobola/ecommerce_terraform_deployment.git
echo " Repository cloned ..."
sleep 2
cd ecommerce_terraform_deployment/frontend

# Install Node.js and npm 
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

#Install the dependencies by running:
npm i

# Set Node.js options for legacy compatibility and start the app:
export NODE_OPTIONS=--openssl-legacy-provider
npm start