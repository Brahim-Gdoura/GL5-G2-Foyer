pipeline {
    agent any

    triggers { githubPush() }

    environment {
        registry = "fouedtra/docker-foyer"
        registryCredential = 'dockerHub'
        gitCredential = 'github-ssh'
        gitRepo = 'git@github.com:Brahim-Gdoura/GL5-G2-Foyer.git'
        gitBranch = 'featureFoyer'
        mavenImage = 'maven:3.9.7-eclipse-temurin-17'
        sonarHostUrl = 'http://sonarqube:9000'
        mavenSettingsId = '532f187c-11c7-4741-8144-c3f690b16583'
    }

    stages {
        stage('CHECKOUT GIT') {
            steps {
                git branch: env.gitBranch, credentialsId: env.gitCredential, url: env.gitRepo
            }
        }

        stage('MVN CLEAN') {
            steps {
                script {
                    docker.image(env.mavenImage).inside {
                        sh 'mvn clean -Dmaven.repo.local=.m2'
                    }
                }
            }
        }

        stage('ARTIFACT CONSTRUCTION') {
            steps {
                script {
                    docker.image(env.mavenImage).inside {
                        sh 'mvn package -Dmaven.test.skip=true -Dmaven.repo.local=.m2'
                    }
                }
            }
        }

        /*stage('UNIT TESTS') {
            steps {
                script {
                    docker.image(env.mavenImage).inside {
                        sh 'mvn test -Dmaven.repo.local=.m2'
                    }
                }
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                }
            }
        }*/

        stage('MVN SONARQUBE') {
            steps {
                withCredentials([string(credentialsId: 'SONAR-TOKEN', variable: 'SONAR_TOKEN')]) {
                    script {
                        docker.image(env.mavenImage).inside("--network=devnet") {
                            sh """
                                mvn -B sonar:sonar \
                                  -Dsonar.host.url=${SONAR_HOST_URL} \
                                  -Dsonar.login=${SONAR_TOKEN} \
                                  -Dmaven.repo.local=.m2
                            """
                        }
                    }
                }
            }
        }

        stage('DEBUG NEXUS CONNECTION') {
            steps {
                script {
                    echo "=== Testing Nexus connectivity from Maven container ==="
                    docker.image(env.mavenImage).inside("--network=devnet") {
                        sh """
                            echo "1. Testing DNS resolution:"
                            ping -c 2 agitated_goodall || echo "Ping failed"
                            
                            echo ""
                            echo "2. Testing Nexus HTTP access with credentials:"
                            curl -u admin:admin123 -I http://agitated_goodall:8081/nexus/content/repositories/snapshots/ || echo "Curl failed"
                            
                            echo ""
                            echo "3. Checking network connectivity:"
                            curl -I http://agitated_goodall:8081/ || echo "Root access failed"
                        """
                    }
                }
            }
        }

        stage('PUBLISH TO NEXUS') {
            steps {
                script {
                    echo "=== Creating Maven settings.xml with Nexus credentials ==="
                    
                    // Créer le settings.xml directement sur l'hôte Jenkins
                    sh """
                        mkdir -p /var/jenkins_home/maven-config
                        cat > /var/jenkins_home/maven-config/settings.xml << 'SETTINGSEOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
  </servers>
</settings>
SETTINGSEOF
                        
                        echo "Settings.xml created. Content:"
                        cat /var/jenkins_home/maven-config/settings.xml
                    """
                    
                    echo "=== Deploying artifact to Nexus ==="
                    
                    // Déployer avec ce settings.xml
                    docker.image(env.mavenImage).inside("--network=devnet -v /var/jenkins_home/maven-config:/maven-config") {
                        sh """
                            echo "Verifying settings.xml is accessible inside container:"
                            ls -la /maven-config/
                            cat /maven-config/settings.xml
                            
                            echo ""
                            echo "Starting Maven deploy:"
                            mvn deploy --settings /maven-config/settings.xml -Dmaven.test.skip=true -Dmaven.repo.local=.m2
                        """
                    }
                }
            }
        }

        stage('BUILD IMAGE') {
            steps {
                script {
                    echo "=== Building Docker image ==="
                    dockerImage = docker.build("${registry}:${BUILD_NUMBER}")
                }
            }
        }

        stage('PUSH IMAGE') {
            steps {
                script {
                    echo "=== Pushing Docker image to registry ==="
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs above for details."
        }
        always {
            echo "Pipeline execution finished at ${new Date()}"
        }
    }
}
