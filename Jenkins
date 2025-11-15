pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'k3s-nginx-jenkins'
        TERRAFORM_DIR = 'awstest/terraform'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'mohamedaminelili02/my-app:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'feature/ReadMeInit',
                url: 'https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git'
            }
        }

        // Maven Build & Test Stages
        stage('Maven Build') {
            steps {
                script {
                    echo "=== Building with Maven ==="
                    sh 'mvn clean compile -f pom.xml'
                }
            }
        }

        stage('Maven Test') {
            steps {
                script {
                    echo "=== Running Tests with Maven ==="
                    sh 'mvn test -f pom.xml'
                }
            }
        }

        stage('Maven Package') {
            steps {
                script {
                    echo "=== Packaging with Maven ==="
                    sh 'mvn package -f pom.xml -DskipTests'
                }
            }
        }

        // Docker Build & Push Stages
        stage('Docker Build') {
            steps {
                script {
                    echo "=== Building Docker Image ==="
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    echo "=== Logging into Docker Hub ==="
                    sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    echo "=== Pushing Docker Image to Docker Hub ==="
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        // Terraform Stages
        stage('Validate Terraform Syntax') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh '''
                        echo "=== Validating Terraform syntax ==="
                        terraform validate

                        echo "=== Checking Terraform format ==="
                        terraform fmt -check

                        echo "=== Syntax validation passed ==="
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
                            echo "=== Initializing Terraform ==="
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
                        echo "=== Final Outputs ==="
                        terraform output || echo "No outputs available"
                    '''
                }
            }

            // Clean up Docker credentials
            sh 'docker logout'
        }
        success {
            echo "✅ Pipeline completed successfully! Application built, tested, and deployed."
        }
        failure {
            echo "❌ Pipeline failed - check the logs above for details"
        }
    }
}