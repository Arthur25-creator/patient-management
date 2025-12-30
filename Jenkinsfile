pipeline {
    agent any

    stages {

        stage('Build Docker Images') {
            steps {
                sh '''
                docker build -t api-gateway ./api-gateway
                docker build -t auth-service ./auth-service
                docker build -t patient-service ./patient-service
                docker build -t billing-service ./billing-service
                docker build -t analytics-service ./analytics-service
                '''
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh 'mvn test -pl integration-test'
            }
        }
    }
}
