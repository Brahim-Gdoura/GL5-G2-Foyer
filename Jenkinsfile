pipeline {
    agent any

    tools {
        maven 'Maven 3.9.9'
        jdk 'jdk17'
    }

    environment {
        MAVEN_OPTS = "-Dmaven.test.failure.ignore=false"
        SONARQUBE_SERVER = 'SonarQubeServer' // Nom du serveur Sonar configuré dans Jenkins
        NEXUS_URL = 'http://nexus:8081/repository/maven-releases/' // URL Nexus (à adapter)
    }

    stages {

        stage('Checkout') {
            steps {
                echo '🔹 Checking out feature/ReadMeInit branch...'
                git branch: 'feature/ReadMeInit', url: 'https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git'
            }
        }

        stage('Build & Test') {
            steps {
                echo '🔹 Building and running tests...'
                sh 'mvn clean verify'
            }
        }

        stage('Test Results') {
            steps {
                echo '🔹 Publishing test results...'
                junit '**/target/surefire-reports/*.xml'
            }
        }

        stage('Code Coverage (JaCoCo)') {
            steps {
                echo '🔹 Publishing JaCoCo report...'
                jacoco execPattern: '**/target/jacoco.exec',
                       classPattern: '**/target/classes',
                       sourcePattern: '**/src/main/java'
            }
        }


        stage('Quality Gate') {
            steps {
                echo '🔹 Checking SonarQube quality gate...'
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }




    }

    post {
        success {
            echo '✅ Build and tests passed successfully!'
        }
        failure {
            echo '❌ Build or tests failed.'
        }
        always {
            echo '📦 Cleaning up workspace...'
            cleanWs()
        }
    }
}
