pipeline {
    agent any
    
    environment {
        SERVICES = 'api-gateway,analytics-service,patient-service,billing-service,auth-service'
        DOCKER_BUILDKIT = '1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out code successfully"
            }
        }
        
        stage('Build All Services') {
            steps {
                script {
                    def services = env.SERVICES.split(',')
                    def parallelBuilds = [:]
                    
                    services.each { service ->
                        parallelBuilds[service.trim()] = {
                            dir(service.trim()) {
                                echo "Building ${service}..."
                                sh """
                                    docker build -t ${service}:${BUILD_NUMBER} .
                                    docker tag ${service}:${BUILD_NUMBER} ${service}:latest
                                    echo "${service} built successfully!"
                                """
                            }
                        }
                    }
                    
                    parallel parallelBuilds
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    if (fileExists('integration-tests')) {
                        dir('integration-tests') {
                            echo "Building and running integration tests..."
                            sh """
                                docker build -t integration-tests:${BUILD_NUMBER} .
                                echo "Integration test image built successfully!"
                                
                                # Run tests in container
                                docker run --rm --name integration-tests-${BUILD_NUMBER} integration-tests:${BUILD_NUMBER}
                            """
                        }
                    } else {
                        echo "No integration-tests directory found, skipping tests"
                    }
                }
            }
        }
        
        stage('Verify Images') {
            steps {
                echo "Verifying all built images..."
                sh """
                    echo "=== Built Images ==="
                    docker images | grep -E "(api-gateway|analytics-service|patient-service|billing-service|auth-service|integration-tests)" || echo "No images found"
                    
                    echo "=== Image Sizes ==="
                    docker images --format "table {{.Repository}}\\t{{.Tag}}\\t{{.Size}}" | grep -E "(api-gateway|analytics-service|patient-service|billing-service|auth-service)"
                """
            }
        }
        
        stage('Build CDK Template') {
		    steps {
		        script {
		            dir('infrastructure') {
		                docker.image('maven:3.9.12-eclipse-temurin-21').inside {
		                    sh '''
		                        # Just use Maven - no CDK CLI needed
		                        mvn compile
		                        mvn exec:java -Dexec.mainClass="com.pm.stack.LocalStack"
		                    '''
		                }
		            }
		        }
		    }
		}
        
        stage('Deploy to LocalStack') {
		    steps {
		        script {
		            dir('infrastructure') {
		                sh '''
		                    export AWS_ACCESS_KEY_ID=test
                            export AWS_SECRET_ACCESS_KEY=test
		                    export AWS_DEFAULT_REGION=us-east-1
		                    chmod +x localstack-deploy.sh
		                    ./localstack-deploy.sh
		                '''
		            }
		        }
		    }
		}
    }
    
    post {
        always {
            echo "Pipeline completed"
            
            // Clean up test containers
            sh '''
                echo "Cleaning up test containers..."
                docker ps -a --filter "name=integration-tests-" -q | xargs -r docker rm -f
            '''
        }
        success {
            echo "✅ Build and Test Pipeline succeeded!"
            sh '''
                echo "=== Final Status ==="
                echo "All services built successfully:"
                docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(api-gateway|analytics-service|patient-service|billing-service|auth-service)" | sort
            '''
        }
        failure {
            echo "❌ Build and Test Pipeline failed!"
            sh '''
                echo "=== Debug Information ==="
                echo "Docker system info:"
                docker system df
                
                echo "Recent containers:"
                docker ps -a --format "table {{.Names}}\\t{{.Status}}\\t{{.Image}}" | head -10
            '''
        }
        cleanup {
            // Optional: Clean up build images to save space
            sh '''
                echo "Cleaning up dangling images..."
                docker image prune -f
            '''
        }
    }
}
