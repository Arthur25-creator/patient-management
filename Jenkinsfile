pipeline {
    agent any

    environment {
        MAVEN_OPTS = '-Dmaven.repo.local=/var/jenkins_home/.m2/repository'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Cache Dependencies') {
            steps {
                sh 'mvn dependency:go-offline -B'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['api-gateway','auth-service','patient-service','billing-service','analytics-service']
                    for (s in services) {
                        sh "docker build --cache-from ${s}:latest -t ${s} ./${s}"
                    }
                }
            }
        }

        stage('Integration Tests') {
            steps {
                sh 'mvn test -pl integration-test'
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f' // optional: clean dangling images to save space
        }
    }
}
