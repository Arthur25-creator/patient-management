#!/bin/bash
set -e

echo "Building all services..."

SERVICES=("api-gateway" "auth-service" "patient-service" "billing-service" "analytics-service")

for service in "${SERVICES[@]}"; do
    echo "Building $service..."
    cd $service
    docker build -t $service:test .
    cd ..
done

echo "Running integration tests..."
cd integration-test
docker build -t integration-test:test .
docker run --rm integration-test:test

echo "✅ All builds and tests completed!"
