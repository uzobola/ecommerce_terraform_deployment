#!/bin/bash

echo "${ssh_key}" > /home/ubuntu/.ssh/uzo_wl5.pem 
kura_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$kura_key" >> /home/ubuntu/.ssh/authorized_keys


# Update system
sudo apt-get update -y


# In the "Frontend" EC2 (React), clone your source code repository
cd /home/ubuntu
echo " Cloning Repository ..."
git clone https://github.com/uzobola/ecommerce_terraform_deployment.git
echo " Repository cloned ..."
sleep 2

# Update package.json
BACKEND_PRIVATE_IP=$(hostname -i | awk '{print $1}')
sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${BACKEND_PRIVATE_IP}:8000/" /home/ubuntu/ecommerce_terraform_deployment/frontend/package.json
cd ecommerce_terraform_deployment/frontend

# Install Node.js and npm 
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sleep 3

#Install the dependencies by running:
npm i

# Set Node.js options for legacy compatibility and start the app:
export NODE_OPTIONS=--openssl-legacy-provider

# Create and append logs as suggested by Jon
mkdir -p /home/ubuntu/logs 
touch /home/ubuntu/logs/frontend.log
# start frontend server
npm start > /home/ubuntu/logs/frontend.log 2>&1 &
