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

        terraformDir = 'terraform'
        awsCredentialsId = 'awsAccessKey'
        awsSessionTokenId = 'awsSessionToken'
        eksClusterName = 'my-kubernetes-foyer'
        awsRegion = 'us-east-1'
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

        stage('MVN SONARQUBE') {
            steps {
                withCredentials([string(credentialsId: 'SONAR-TOKEN', variable: 'SONAR_TOKEN')]) {
                    script {
                        configFileProvider([configFile(fileId: env.mavenSettingsId, variable: 'MAVEN_SETTINGS')]) {
                            docker.image(env.mavenImage).inside {
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
                        docker.image(env.mavenImage).inside {
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

        stage('SETUP TERRAFORM') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: env.awsCredentialsId, variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'awsSecretKey', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: env.awsSessionTokenId, variable: 'AWS_SESSION_TOKEN')
                    ]) {
                        sh """
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                            export AWS_DEFAULT_REGION=${env.awsRegion}

                            cd ${env.terraformDir}
                            terraform init
                            terraform plan -out=tfplan
                            terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('UPDATE KUBECONFIG') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: env.awsCredentialsId, variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'awsSecretKey', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: env.awsSessionTokenId, variable: 'AWS_SESSION_TOKEN')
                    ]) {
                        sh """
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                            export AWS_DEFAULT_REGION=${env.awsRegion}

                            aws eks update-kubeconfig --name ${env.eksClusterName} --region ${env.awsRegion}
                        """
                    }
                }
            }
        }

        stage('DEPLOY TO EKS') {
            steps {
                script {
                    sh """
                        kubectl apply -f k8s/mysql-deployment.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }

        stage('VERIFY DEPLOYMENT') {
            steps {
                script {
                    sh """
                        kubectl get pods -o wide
                        kubectl get svc -o wide
                    """
                }
            }
        }
    }
}



