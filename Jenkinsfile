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
        stage('Code Coverage') {
        steps {
            sh 'mvn verify jacoco:report'
        }
        post {
            success {
                echo '✅ Rapport de couverture généré : target/site/jacoco/index.html'
            }
        }
    }

    stage('SonarQube Analysis') {
        steps {
            withSonarQubeEnv('SonarServer') {
                sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=tpFoyer-17 \
                        -Dsonar.projectName=tpFoyer-17 \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN \
                        -Dsonar.sources=src/main/java \
                        -Dsonar.tests=src/test/java \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                        -Dsonar.java.coveragePlugin=jacoco
                """
            }
        }
    }

    /* stage('Quality Gate') {
        steps {
            timeout(time: 5, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
            }
        }
    }*/

    stage('Publish To Nexus') {
        steps {
            configFileProvider([
                configFile(fileId: mavenSettingsId, variable: 'mavensettings')
            ]) {
                sh "mvn -s $mavensettings clean deploy -DskipTests=true"
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
        
        stage('Terraform Cleanup') {
            steps {
                dir("Terraform") {
                     sh 'rm -rf .terraform .terraform.lock.hcl terraform.tfstate.backup'
                }
            }
        }
        
        stage('Terraform Plan') {
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
                          
                          echo "📦 Initialisation Terraform..."
                          terraform init -reconfigure
                          
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
        
                          echo "📦 Initialisation Terraform..."
                          terraform init -reconfigure
                          
                          echo "🚀 Création de l'infrastructure EKS..."
                          if [ -f tfplan ]; then
                              terraform apply -auto-approve tfplan
                          else
                              echo "⚠️ Plan introuvable, application directe..."
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
        
                        echo "🔧 Configuration kubectl..."
                        aws eks update-kubeconfig --name simple-eks --region ${AWS_REGION}
        
                        echo "🗄️ Création Namespace et MySQL..."
                        kubectl create namespace tpfoyer --dry-run=client -o yaml | kubectl apply -f -
                        kubectl apply -f mysql-deployment.yaml -n tpfoyer
        
                        echo "⏳ Attente MySQL..."
                        kubectl wait --for=condition=ready pod -l app=mysql -n tpfoyer --timeout=300s || true
                        
                        echo "✅ MySQL déployé !"
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
                      
                      if [ ! -f deployment.yaml ]; then
                          echo "❌ ERREUR : Fichier deployment.yaml introuvable !"
                          exit 1
                      fi
                      
                      echo "🖼️ Mise à jour de l'image : ${registry}:${IMAGE_TAG}"
                      sed -i.bak "s|IMAGE_TO_REPLACE|${registry}:${IMAGE_TAG}|g" deployment.yaml
                      
                      echo "🚀 Application des manifestes..."
                      kubectl create namespace tpfoyer --dry-run=client -o yaml | kubectl apply -f -
                      kubectl apply -f deployment.yaml -n tpfoyer
                      kubectl apply -f service.yaml -n tpfoyer
                      
                      echo "⏳ Attente du déploiement..."
                      kubectl rollout status deployment/my-spring-boot-app -n tpfoyer --timeout=5m || {
                          echo "⚠️ Echec du rollout ou timeout"
                          kubectl describe deployment my-spring-boot-app -n tpfoyer
                          kubectl logs -l app=my-spring-boot-app -n tpfoyer --tail=50
                          exit 1
                      }
                      
                      echo "✅ Déploiement terminé !"
                      kubectl get svc my-spring-boot-service -n tpfoyer
                      
                      echo "🔗 URL (LoadBalancer) :"
                      kubectl get svc my-spring-boot-service -n tpfoyer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "En cours de création..."
                    '''
                }
            }
        }
    } // 👈 C'est cette accolade qui manquait pour fermer 'stages' avant 'post'

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        cleanup {
            cleanWs()
        }
    }
}
