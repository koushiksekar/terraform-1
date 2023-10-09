pipeline {
    agent any
    parameters {
        choice choices: ['"region=us-east-1"', '"region=us-east-2"'], description: 'regions parameter', name: 'region'
     }

    stages {
        stage('git repo') {
            steps {
                git 'https://github.com/koushiksekar/terraform'
            }
        }
        stage('terraform infra creation') {
            steps {
                script {
                   sh 'terraform init'
                } 
            }
        }
        stage('terraform apply') {
            steps {
                script {
                     def selectedVars = params.region
                     def varArray = selectedVars.split(',') // Split the selected variables
                     // Run Terraform apply with the selected variables
                       sh "terraform apply ${varArray.collect { "-var ${it.trim()}" }.join(' ')} -auto-approve"
                }      
            }
        }
    }
}  


