pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Terraform Workspace') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform workspace new k3s-jenkins || true'
                    sh 'terraform workspace select k3s-jenkins'
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform validate'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform plan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Show Outputs') {
            steps {
                dir('awstest/terraform') {
                    sh 'terraform output'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo '✅ K3s cluster deployed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
