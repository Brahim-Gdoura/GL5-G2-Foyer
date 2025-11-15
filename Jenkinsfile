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
        SONAR_AUTH_TOKEN = credentials('sonarqube_token')
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
                sh 'mvn test -Dspring.profiles.active=test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Code Coverage') {
            steps {
                sh 'mvn verify jacoco:report -Dspring.profiles.active=test'
            }
            post {
                success {
                    echo '✅ Rapport de couverture généré : target/site/jacoco/index.html'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
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

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

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

        stage('Deploy with Docker Compose') {
            steps {
                sh 'docker-compose down || true'
                sh 'docker-compose up -d --build'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        success {
            echo '🎉 Build & Tests & SonarQube OK !'
        }
        failure {
            echo '❌ Pipeline échouée'
        }
    }
}




