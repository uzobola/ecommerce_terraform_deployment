#!/bin/bash

# In the "Backend" EC2 (Django) clone your source code repository and install "python3.9", "python3.9-venv", and "python3.9-dev"
sudo apt-get update -y
sudo apt-get upgrade -y
sleep 2


# Install required Python packages
echo " Setting up python environment" 
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.9 python3.9-venv python3.9-dev -y
sleep 3

# Clone Repository
echo " Cloning Repository ..."
sleep 2 
git clone https://github.com/uzobola/ecommerce_terraform_deployment.git
echo " Repository cloned ..."
sleep 2
cd ecommerce_terraform_deployment/



# Create a python3.9 virtual environment (venv), activate it, and install the dependencies
echo " Activating python environment"
python3.9 -m venv venv
source venv/bin/activate
cd backend/
pip install pip --upgrade
pip  install -r requirements.txt
cd my_project/


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