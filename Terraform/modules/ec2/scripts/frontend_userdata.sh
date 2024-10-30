#!/bin/bash

echo "${ssh_key}" > /home/ubuntu/.ssh/uzo_wl5.pem 
kura_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$kura_key" >> /home/ubuntu/.ssh/authorized_keys


# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# In the "Frontend" EC2 (React), clone your source code repository
cd /home/ubuntu
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