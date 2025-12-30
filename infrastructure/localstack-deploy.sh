#!/bin/bash
set -e # Stops the script if any command fails
set -x

aws --endpoint-url=http://localhost:4566 cloudformation  wait stack-delete-complete \
    --stack-name patient-management

echo "Deploying CloudFormation stack..."
aws --endpoint-url=http://localhost:4566 cloudformation deploy \
    --stack-name patient-management \
    --template-file "./cdk.out/localstack.template.json" || echo "CloudFormation deploy failed"


aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers \
    --query "LoadBalancers[0].DNSName" --output text
