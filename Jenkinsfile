pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'k3s-universite-app'
        TERRAFORM_DIR = 'aws/terraform'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'feature/universite', 
                    url: 'https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git'
            }
        }
        
        stage('Validate Terraform') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh '''
                        echo "=== Validating Terraform ==="
                        terraform validate
                        terraform fmt -check || true
                    '''
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([file(
                        credentialsId: 'aws-credentials',
                        variable: 'AWS_CREDS_FILE'
                    )]) {
                        sh '''
                            export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDS_FILE"
                            terraform init -upgrade
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([file(
                        credentialsId: 'aws-credentials',
                        variable: 'AWS_CREDS_FILE'
                    )]) {
                        sh '''
                            export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDS_FILE"
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([file(
                        credentialsId: 'aws-credentials',
                        variable: 'AWS_CREDS_FILE'
                    )]) {
                        sh '''
                            export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDS_FILE"
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Get Cluster Info') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([file(
                        credentialsId: 'aws-credentials',
                        variable: 'AWS_CREDS_FILE'
                    )]) {
                        sh '''
                            export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDS_FILE"
                            echo "=== K3s Cluster Information ==="
                            terraform output
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            dir(env.TERRAFORM_DIR) {
                withCredentials([file(
                    credentialsId: 'aws-credentials',
                    variable: 'AWS_CREDS_FILE'
                )]) {
                    sh '''
                        export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDS_FILE"
                        terraform output || echo "No outputs available"
                    '''
                }
            }
        }
        success {
            echo '✅ K3s cluster deployed successfully!'
        }
        failure {
            echo '❌ Pipeline failed - check logs for details'
        }
    }
}
