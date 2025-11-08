pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_project_name = 'k3s-jenkins'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/votre-username/votre-repo-terraform.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Test Deployment') {
            steps {
                script {
                    def ip = sh(
                        script: 'terraform output -raw k3s_server_public_ip',
                        returnStdout: true
                    ).trim()
                    
                    echo "K3s Server IP: ${ip}"
                    
                    // Test basique de connexion SSH
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ip} 'sudo kubectl get nodes'"
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
            // Nettoyage optionnel
            // sh 'terraform destroy -auto-approve'
        }
        success {
            echo '✅ K3s cluster deployed successfully!'
            script {
                def ip = sh(
                    script: 'terraform output -raw k3s_server_public_ip',
                    returnStdout: true
                ).trim()
                echo "🌐 K3s Dashboard: http://${ip}:30000"
            }
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
