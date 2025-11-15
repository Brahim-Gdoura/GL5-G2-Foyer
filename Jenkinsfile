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
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        docker.image(env.mavenImage).inside {
                            sh 'mvn clean --settings $MAVEN_SETTINGS -Dmaven.repo.local=.m2'
                        }
                    }
                }
            }
        }

        stage('ARTIFACT CONSTRUCTION') {
            steps {
                script {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        docker.image(env.mavenImage).inside {
                            sh 'mvn package --settings $MAVEN_SETTINGS -Dmaven.test.skip=true -Dmaven.repo.local=.m2'
                        }
                    }
                }
            }
        }

        /*stage('UNIT TESTS') {
            steps {
                script {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        docker.image(env.mavenImage).inside {
                            sh 'mvn test --settings $MAVEN_SETTINGS -Dmaven.repo.local=.m2'
                        }
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
                        configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                            docker.image(env.mavenImage).inside("--network=devnet") {
                                withEnv(["SONAR_HOST_URL=${env.sonarHostUrl}"]) {
                                    sh '''
                                        mvn -B sonar:sonar \
                                          --settings $MAVEN_SETTINGS \
                                          -Dsonar.host.url=$SONAR_HOST_URL \
                                          -Dsonar.login=$SONAR_TOKEN \
                                          -Dmaven.repo.local=.m2
                                    '''
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('PUBLISH TO NEXUS') {
            steps {
                script {
                    configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                        docker.image(env.mavenImage).inside("--network=devnet") {
                            sh 'mvn deploy --settings $MAVEN_SETTINGS -Dmaven.test.skip=true -Dmaven.repo.local=.m2'
                        }
                    }
                }
            }
        }

        stage('BUILD IMAGE') {
            steps {
                script {
                    dockerImage = docker.build("${registry}:${BUILD_NUMBER}")
                }
            }
        }

        stage('PUSH IMAGE') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}


