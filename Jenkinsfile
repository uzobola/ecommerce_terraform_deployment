pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        sh '''#!/bin/bash
		    # This  creates the python  virtual environment
          python3.9 -m venv venv
                
		    # This activates the python virtual environment
		      source venv/bin/activate

		    # This installs any dependencies
        pip install pip --upgrade
        pip install -r backend/requirements.txt

        # Install frontend dependencies
        cd frontend
        npm install
        cd ..

        '''
     }
   }
    stage ('Test') {
      steps {
        sh '''#!/bin/bash
        <code to activate virtual environment>
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
          withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('Terraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
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
