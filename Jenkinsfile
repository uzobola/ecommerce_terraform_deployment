pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh '''#!/bin/bash
                    # This creates the python virtual environment
                    cd /home/ubuntu/ecommerce_terraform_deployment/
                    python3 -m venv venv
                    
                    # This activates the python virtual environment
                    source venv/bin/activate
                    # This installs any dependencies
                    pip install pip --upgrade
                    pip install --upgrade Pillow
                    pip install -r backend/requirements.txt
                    
                    # Install frontend dependencies
                    cd frontend
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs

                    cd frontend
                    export NODE_OPTIONS=--openssl-legacy-provider
                    export CI=false
                    npm ci

                    cd ..
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''#!/bin/bash
                    source venv/bin/activate
                    pip install pytest-django
                    python backend/manage.py makemigrations
                    python backend/manage.py migrate
                    pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
                '''
            }
        }

        stage('Init') {

            steps {
                dir('Terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('Terraform') {
                        sh '''
                            terraform plan -out plan.tfplan \
                            -var="aws_access_key=${aws_access_key}" \
                            -var="aws_secret_key=${aws_secret_key}" \
                            -var-file="infrastructure.auto.tfvars"
                        '''
                    }
                }
            }
        }
        
        stage('Apply') {
            steps {
                dir('Terraform') {
                    sh 'terraform apply plan.tfplan'
                }
            }
        }
    }
}
