pipeline {
    agent any
    parameters {
        choice choices: ['us-east-1', 'us-east-2'], description: 'regions parameter', name: 'region'
     }

    stages {
        stage('terraform infra creation') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform apply -var "region=${params.region}" -auto-approve'
            }
        }
    }
}  