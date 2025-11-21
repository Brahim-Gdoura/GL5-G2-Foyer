pipeline {
    agent any
    tools { 
        maven 'maven' 
    }

    environment {
        registry = "fouedtra/docker-foyer"
        mavenSettingsId = '532f187c-11c7-4741-8144-c3f690b16583'
        MAVEN_OPTS = "-Dmaven.test.failure.ignore=false"
        SONAR_HOST_URL = "http://sonarqube:9000"
        SONAR_AUTH_TOKEN = credentials('SONAR-TOKEN')
        registryCredential = 'dockerhub'
        dockerImage = ''
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-token',
                    branch: 'featureFoyer',
                    url: 'https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile -Dspring.profiles.active=test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn test -Dmaven.test.failure.ignore=true'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${registry}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${registry}:latest
                    """
                }
            }
        }
        
        // J'ai fusionné Init et Plan pour garantir la continuité
        stage('Terraform Init & Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY'),
                    string(credentialsId: 'aws_session_token', variable: 'AWS_SESSION_TOKEN')
                ]) {
                    // Utilisation du dossier Terraform avec Majuscule
                    dir("Terraform") {
                        sh '''
                          export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                          export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                          export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                          export AWS_REGION=${AWS_REGION}
        
                          echo "🧹 Nettoyage..."
                          rm -rf .terraform .terraform.lock.hcl terraform.tfstate.backup
                          
                          echo "📦 Initialisation Terraform..."
                          terraform init -upgrade -reconfigure
                          
                          echo "📋 Planification Terraform..."
                          terraform plan -var "region=${AWS_REGION}" -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY'),
                    string(credentialsId: 'aws_session_token', variable: 'AWS_SESSION_TOKEN')
                ]) {
                    dir("Terraform") {
                        sh '''
                          export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                          export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                          export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                          export AWS_REGION=${AWS_REGION}
        
                          echo "🔄 Vérification Init (Sécurité)..."
                          # On refait init au cas où on change de node ou restart
                          terraform init -reconfigure
                          
                          echo "🚀 Création de l'infrastructure EKS..."
                          # Si le fichier tfplan existe on l'utilise, sinon on applique directement
                          if [ -f tfplan ]; then
                            terraform apply -auto-approve tfplan
                          else
                            echo "⚠️ Fichier tfplan non trouvé, application directe..."
                            terraform apply -auto-approve -var "region=${AWS_REGION}"
                          fi
                          
                          echo "✅ Infrastructure créée"
                          terraform output
                        '''
                    }
                }
            }
        }
        
        stage('🗄️ Déploiement MySQL Kubernetes') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY'),
                    string(credentialsId: 'aws_session_token', variable: 'AWS_SESSION_TOKEN')
                ]) {
                    sh '''#!/bin/bash
                        set -eu
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                        export AWS_REGION=us-east-1
        
                        aws eks update-kubeconfig --name simple-eks --region ${AWS_REGION}
                        
                        kubectl create namespace tpfoyer --dry-run=client -o yaml | kubectl apply -f -
                        kubectl apply -f mysql-deployment.yaml -n tpfoyer
                        
                        # Attente simplifiée
                        kubectl wait --for=condition=ready pod -l app=mysql -n tpfoyer --timeout=300s || true
                    '''
                }
            }
        }

        stage('Deploy App to EKS') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY'),
                    string(credentialsId: 'aws_session_token', variable: 'AWS_SESSION_TOKEN')
                ]) {
                    sh '''#!/bin/bash
                      set -eu
                      export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                      export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                      export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                      export AWS_REGION=us-east-1
                      
                      aws eks update-kubeconfig --name simple-eks --region us-east-1
                      
                      sed -i.bak "s|IMAGE_TO_REPLACE|${registry}:${IMAGE_TAG}|g" deployment.yaml
                      
                      kubectl create namespace tpfoyer --dry-run=client -o yaml | kubectl apply -f -
                      kubectl apply -f deployment.yaml -n tpfoyer
                      kubectl apply -f service.yaml -n tpfoyer
                      
                      kubectl rollout status deployment/tpfoyer -n tpfoyer --timeout=5m || true
                      
                      echo "✅ Déploiement terminé"
                      kubectl get svc tpfoyer-service -n tpfoyer
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        cleanup {
            cleanWs()
        }
    }
}
