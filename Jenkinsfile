pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'k3s-nginx-jenkins'
        TERRAFORM_DIR = 'terraform'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/your-username/your-repo.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([awsCredentials(
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                            terraform init -upgrade
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([awsCredentials(
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                            terraform plan -var="aws_region=${AWS_REGION}" \
                                          -var="project_name=${PROJECT_NAME}" \
                                          -var="key_pair_name=my-key-pair" \
                                          -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([awsCredentials(
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Get Cluster Info') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh '''
                        terraform output k3s_cluster_info
                        terraform output nginx_service_info
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    script {
                        def PUBLIC_IP = sh(
                            script: 'terraform output -raw k3s_master_public_ip',
                            returnStdout: true
                        ).trim()
                        
                        echo "K3s Cluster Public IP: ${PUBLIC_IP}"
                        echo "NGINX should be accessible at: http://${PUBLIC_IP}:30080"
                        
                        // Wait for cluster to be ready
                        sleep(time: 30, unit: 'SECONDS')
                    }
                }
            }
        }
    }
    
    post {
        always {
            dir(env.TERRAFORM_DIR) {
                sh 'terraform output || true'
            }
        }
        success {
            emailext (
                subject: "SUCCESS: K3s Cluster Deployment - ${env.JOB_NAME}",
                body: """
                K3s Kubernetes cluster with NGINX deployed successfully!
                
                Cluster Information:
                - Public IP: Check Terraform outputs
                - NGINX Service: Access via NodePort (30000-32767 range)
                
                Jenkins Build: ${env.BUILD_URL}
                """,
                to: 'your-email@example.com'
            )
        }
        failure {
            emailext (
                subject: "FAILED: K3s Cluster Deployment - ${env.JOB_NAME}",
                body: """
                K3s Kubernetes cluster deployment failed!
                
                Please check Jenkins logs: ${env.BUILD_URL}
                """,
                to: 'your-email@example.com'
            )
        }
    }
}