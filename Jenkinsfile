pipeline {
    agent any

    triggers { githubPush() }

    environment {
        registry = "fouedtra/docker-foyer"
        registryCredential = 'dockerHub'
        gitCredential = 'github-ssh'
        gitRepo = 'git@github.com:Brahim-Gdoura/GL5-G2-Foyer.git'
        gitBranch = 'featureFoyer'
        projectDir = 'GL5-G2-Foyer'
        mavenSettingsId = '532f187c-11c7-4741-8144-c3f690b16583'
        sonarHostUrl = 'http://sonarqube:9000'
    }

    stages {
        stage('Checkout Git') {
            steps {
                git branch: env.gitBranch, credentialsId: env.gitCredential, url: env.gitRepo
            }
        }

        stage('Clean') {
            steps {
                dir(env.projectDir) {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        sh 'mvn clean --settings $MAVEN_SETTINGS'
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                dir(env.projectDir) {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        sh 'mvn package --settings $MAVEN_SETTINGS -Dmaven.test.skip=true'
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir(env.projectDir) {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        sh 'mvn test --settings $MAVEN_SETTINGS'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: false, testResults: "${env.projectDir}/target/surefire-reports/*.xml"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR-TOKEN', variable: 'SONAR_TOKEN')]) {
                    dir(env.projectDir) {
                        configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                            sh """
                                mvn sonar:sonar \
                                    --settings \$MAVEN_SETTINGS \
                                    -Dsonar.host.url=${env.sonarHostUrl} \
                                    -Dsonar.login=\$SONAR_TOKEN
                            """
                        }
                    }
                }
            }
        }

        stage('Publish to Nexus') {
            steps {
                dir(env.projectDir) {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        sh 'mvn deploy --settings $MAVEN_SETTINGS -Dmaven.test.skip=true'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${registry}:${BUILD_NUMBER}", "./${projectDir}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
    }

    post {
        success { echo 'Pipeline succeeded!' }
        failure { echo 'Pipeline failed!' }
    }
}

