#!/bin/bash

kura_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$kura_key" >> /home/ubuntu/.ssh/authorized_keys



# In the "Backend" EC2 (Django) clone your source code repository and install "python3.9", "python3.9-venv", and "python3.9-dev"
sudo apt-get update -y
sleep 2


# Clone Repository
cd /home/ubuntu
echo " Cloning Repository ..."
sleep 2 
git clone https://github.com/uzobola/ecommerce_terraform_deployment.git
echo " Repository cloned ..."
sleep 2
cd ecommerce_terraform_deployment/

# Update backend settings.py configuration
BACKEND_PRIVATE_IP=$(hostname -i | awk '{print $1}')
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"$BACKEND_PRIVATE_IP\"\]/" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py


# Install required Python packages
echo " Setting up python environment" 
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.9 python3.9-venv python3.9-dev -y
sleep 3



# Create a python3.9 virtual environment (venv), activate it, and install the dependencies
echo " Activating python environment"
python3.9 -m venv venv
source venv/bin/activate
cd backend/
pip install pip --upgrade
pip  install -r requirements.txt


# Configure RDS Database
# Uncomment and configure RDS DB in settings.py
sed -i "s/#\s*'NAME': 'your_db_name'/'NAME': '${db_name}'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'USER': 'your_username'/'USER': '${db_username}'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'PASSWORD': 'your_password'/'PASSWORD': '${db_password}'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'HOST': 'your-rds-endpoint.amazonaws.com'/'HOST': '${rds_endpoint}'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'ENGINE': 'django.db.backends.postgresql'/'ENGINE': 'django.db.backends.postgresql'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'PORT': '5432'/'PORT': '5432'/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*},/},/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py
sed -i "s/#\s*'sqlite': {/'sqlite': {/g" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py


# Create the tables in RDS
python manage.py makemigrations account
python manage.py makemigrations payments
python manage.py makemigrations product
python manage.py migrate

# Migrate the data from SQLite to RDS
python manage.py dumpdata --database=sqlite --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > datadump.json
python manage.py loaddata datadump.json
sleep 5

# Start the Django server by running:
echo "Starting Django Server"
python manage.py runserver 0.0.0.0:8000
