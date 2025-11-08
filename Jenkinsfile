pipeline {
    agent any

    environment {
        terraformDir = 'terraform'
        awsCredentialsId = 'aws-credentials'
        kubeConfigCredentialId = 'kubeconfig-credentials'
    }

    stages {

        stage('Test AWS Credentials') {
            steps {
                withCredentials([file(credentialsId: awsCredentialsId, variable: 'AWS_CREDENTIALS_FILE')]) {
                    script {
                        // Read AWS credentials file
                        def awsCredentials = readFile(AWS_CREDENTIALS_FILE).trim().split("\n")

                        // Extract keys and token
                        env.AWS_ACCESS_KEY_ID = awsCredentials.find { it.startsWith("aws_access_key_id") }.split("=")[1].trim()
                        env.AWS_SECRET_ACCESS_KEY = awsCredentials.find { it.startsWith("aws_secret_access_key") }.split("=")[1].trim()
                        env.AWS_SESSION_TOKEN = awsCredentials.find { it.startsWith("aws_session_token") }?.split("=")[1]?.trim()

                        // Optional: Linux paths for AWS config
                        env.AWS_CONFIG_FILE = "${HOME}/.aws/config"
                        env.AWS_SHARED_CREDENTIALS_FILE = AWS_CREDENTIALS_FILE

                        echo "AWS Access Key ID: ${env.AWS_ACCESS_KEY_ID}"
                        echo "AWS Credentials File Loaded"
                    }
                }
            }
        }

        stage('SETUP TERRAFORM') {
            steps {
                echo "Before entering Terraform directory"
                dir(terraformDir) {
                    echo "In Terraform directory"
                    script {
                        echo "AWS Access Key ID: ${env.AWS_ACCESS_KEY_ID}"
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('UPDATE KUBECONFIG') {
            steps {
                script {
                    withCredentials([file(credentialsId: awsCredentialsId, variable: 'AWS_CREDENTIALS_FILE')]) {
                        sh 'aws eks update-kubeconfig --name mykubernetes --region us-east-1'
                    }
                }
            }
        }

        stage('DEPLOY TO AWS KUBERNETES') {
            steps {
                script {
                    withCredentials([file(credentialsId: awsCredentialsId, variable: 'AWS_CREDENTIALS_FILE')]) {
                        env.KUBECONFIG = "${HOME}/.kube/config"
                        sh 'aws sts get-caller-identity'
                        echo "Kubeconfig content: ${readFile(env.KUBECONFIG).trim()}"
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                    }
                }
            }
        }

        // Optional: destroy infrastructure
        /*
        stage('TEARDOWN TERRAFORM') {
            steps {
                dir(terraformDir) {
                    withCredentials([file(credentialsId: awsCredentialsId, variable: 'AWS_CREDENTIALS_FILE')]) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
        */
    }
}
