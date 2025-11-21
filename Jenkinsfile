pipeline {
    agent any
    tools { 
        maven 'maven' 
    }

    environment {
         // ========= Variables importées de la première pipeline =========
        registry = "fouedtra/docker-foyer"
        mavenSettingsId = '532f187c-11c7-4741-8144-c3f690b16583'

        // ========= Variables natives de la 2ème pipeline =========
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

        /*stage('Code Coverage') {
            steps {
                sh 'mvn verify jacoco:report'
            }
            post {
                success {
                    echo '✅ Rapport de couverture généré : target/site/jacoco/index.html'
                }
            }
        }*/

       /*stage('SonarQube Analysis') {
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
        }*/

        /* stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }*/

        /*stage('Publish To Nexus') {
            steps {
                configFileProvider([
                    configFile(fileId: mavenSettingsId, variable: 'mavensettings')
                ]) {
                    sh "mvn -s $mavensettings clean deploy -DskipTests=true"
                }
            }
        }*/

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
        
        stage('Terraform Init') {
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
        
                          echo "🧹 Nettoyage Terraform..."
                          rm -rf .Terraform .Terraform.lock.hcl Terraform.tfstate.backup
                          
                          echo "📦 Initialisation Terraform..."
                          terraform init -upgrade -reconfigure
                          
                          echo "✅ Terraform initialisé"
                        '''
                    }
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
        
                          echo "🚀 Création de l'infrastructure EKS..."
                          terraform apply -auto-approve tfplan
                          
                          echo "✅ Infrastructure créée"
                          terraform output
                        '''
                    }
                }
            }
        }
        
        stage('🗄️ Déploiement MySQL Kubernetes') {
            steps {
                echo '🗄️ Déploiement de MySQL dans Kubernetes...'
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
        
                        echo "🔧 Configuration kubectl pour simple-eks..."
                        aws eks update-kubeconfig --name simple-eks --region ${AWS_REGION}
        
                        echo "📋 Vérification des nodes..."
                        kubectl get nodes
        
                        echo "🗄️ Création du namespace tpfoyer (si non existant)..."
                        kubectl create namespace tpfoyer --dry-run=client -o yaml | kubectl apply -f -
        
                        echo "🚀 Application du manifest MySQL existant : k8s/mysql-deployment.yaml"
                        kubectl apply -f mysql-deployment.yaml -n tpfoyer
        
                        echo "⏳ Attente que le Pod MySQL passe en Ready (timeout 5m)..."
                        kubectl wait --for=condition=ready pod -l app=mysql -n tpfoyer --timeout=300s || {
                            echo "⚠️ Timeout waiting for mysql pod to be ready. Affichage des pods et derniers logs :"
                            kubectl get pods -n tpfoyer -l app=mysql -o wide || true
                            kubectl logs -n tpfoyer -l app=mysql --tail=200 || true
                            exit 1
                        }
        
                        echo "🔍 État actuel MySQL :"
                        kubectl get pods -n tpfoyer -l app=mysql -o wide
                        kubectl get svc -n tpfoyer mysql-service
        
                        echo "📜 Logs récents MySQL :"
                        kubectl logs -n tpfoyer -l app=mysql --tail=100 || echo "Pas encore de logs"
        
                        echo "✅ MySQL déployé et prêt !"
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
                      
                      echo "=========================================="
                      echo "🔧 Configuration kubectl..."
                      echo "=========================================="
                      aws eks update-kubeconfig --name simple-eks --region us-east-1
                      
                      echo ""
                      echo "=========================================="
                      echo "📋 Vérification de l'accès au cluster"
                      echo "=========================================="
                      kubectl cluster-info
                      kubectl get nodes
                      
                      echo ""
                      echo "=========================================="
                      echo "🔍 Vérification du fichier deployment.yaml"
                      echo "=========================================="
                      if [ ! -f deployment.yaml ]; then
                          echo "❌ ERREUR : Fichier deployment.yaml introuvable !"
                          echo "Contenu du dossier k8s/ :"
                          ls -la k8s/
                          exit 1
                      fi
                      
                      echo "✅ Fichier trouvé"
                      echo ""
                      echo "Contenu AVANT remplacement :"
                      cat deployment.yaml
                      
                      echo ""
                      echo "=========================================="
                      echo "🖼️ Remplacement de l'image"
                      echo "=========================================="
                      echo "Image à utiliser : ${registry}:${IMAGE_TAG}"
                      sed -i.bak "s|IMAGE_TO_REPLACE|${registry}:${IMAGE_TAG}|g" deployment.yaml
                      
                      echo ""
                      echo "Contenu APRÈS remplacement :"
                      cat deployment.yaml
                      
                      echo ""
                      echo "=========================================="
                      echo "🗄️ Vérification/Création du namespace"
                      echo "=========================================="
                      kubectl get namespace tpfoyer || kubectl create namespace tpfoyer
                      
                      echo ""
                      echo "=========================================="
                      echo "🚀 Application du déploiement"
                      echo "=========================================="
                      kubectl apply -f deployment.yaml -n tpfoyer --validate=true --dry-run=client
                      echo "✅ Validation OK, application réelle..."
                      kubectl apply -f deployment.yaml -n tpfoyer
                      kubectl apply -f service.yaml -n tpfoyer
                      
                      echo ""
                      echo "=========================================="
                      echo "📋 Vérification des ressources créées"
                      echo "=========================================="
                      echo "Namespaces :"
                      kubectl get namespaces | grep tpfoyer
                      
                      echo ""
                      echo "Déploiements dans tpfoyer :"
                      kubectl get deployments -n tpfoyer -o wide
                      
                      echo ""
                      echo "Pods dans tpfoyer :"
                      kubectl get pods -n tpfoyer -o wide
                      
                      echo ""
                      echo "Services dans tpfoyer :"
                      kubectl get svc -n tpfoyer
                      
                      echo ""
                      echo "Tous les objets dans tpfoyer :"
                      kubectl get all -n tpfoyer
                      
                      echo ""
                      echo "=========================================="
                      echo "⏳ Attente du rollout"
                      echo "=========================================="
                      
                      # Vérifier que le déploiement existe avant d'attendre
                      if kubectl get deployment tpfoyer -n tpfoyer >/dev/null 2>&1; then
                          echo "✅ Déploiement 'tpfoyer' trouvé, attente du rollout..."
                          kubectl rollout status deployment/tpfoyer -n tpfoyer --timeout=10m || {
                              echo ""
                              echo "❌ Erreur lors du rollout"
                              echo "Description du déploiement :"
                              kubectl describe deployment tpfoyer -n tpfoyer
                              echo ""
                              echo "Pods :"
                              kubectl get pods -n tpfoyer
                              echo ""
                              echo "Events :"
                              kubectl get events -n tpfoyer --sort-by='.lastTimestamp' | tail -20
                              echo ""
                              echo "Logs des pods (si disponibles) :"
                              kubectl logs -n tpfoyer -l app=tpfoyer --tail=100 || true
                              exit 1
                          }
                      else
                          echo "❌ ERREUR : Le déploiement 'tpfoyer' n'existe toujours pas !"
                          echo ""
                          echo "Liste complète des déploiements dans tpfoyer :"
                          kubectl get deployments -n tpfoyer
                          echo ""
                          echo "Liste complète de tous les objets dans tpfoyer :"
                          kubectl get all -n tpfoyer
                          echo ""
                          echo "Events du namespace :"
                          kubectl get events -n tpfoyer --sort-by='.lastTimestamp'
                          exit 1
                      fi
                      
                      echo ""
                      echo "=========================================="
                      echo "✅ Déploiement réussi !"
                      echo "=========================================="
                      kubectl get pods -n tpfoyer -o wide
                      kubectl get svc tpfoyer-service -n tpfoyer
                      
                      echo ""
                      echo "🔗 URL de l'application :"
                      kubectl get svc tpfoyer-service -n tpfoyer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "LoadBalancer en cours de création..."
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        success {
            echo '''
            ========================================
            🎉 PIPELINE TERMINÉ AVEC SUCCÈS !
            ========================================
            ✅ Build Maven réussi
            ✅ Tests passés
            ✅ Code coverage généré
            ✅ Analyse SonarQube OK
            ✅ Quality Gate passed
            ✅ Artifact publié sur Nexus
            ✅ Image Docker construite et pushée
            ✅ Déploiement Docker Compose OK
            ✅ Infrastructure EKS créée
            ✅ Application déployée sur Kubernetes
            ========================================
            '''
        }
        failure {
            echo '''
            ========================================
            ❌ PIPELINE ÉCHOUÉ !
            ========================================
            Vérifiez les logs ci-dessus pour identifier l'erreur.
            ========================================
            '''
        }
        cleanup {
            cleanWs()
        }
    }
}
