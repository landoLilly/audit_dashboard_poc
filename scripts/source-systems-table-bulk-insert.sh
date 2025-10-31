#!/bin/bash

ENDPOINT="http://localhost:8000"

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name SourceSystems \
    --item '{
    "SystemId": {"N": "1"},
    "SystemName": {"S": "WebPortal"},
    "Description": {"S": "Main customer-facing web portal"},
    "SystemType": {"S": "Application"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
}'

echo "Inserted record 1"

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name SourceSystems \
    --item '{
    "SystemId": {"N": "2"},
    "SystemName": {"S": "RestAPI"},
    "Description": {"S": "RESTful API for third-party integrations"},
    "SystemType": {"S": "Service"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
}'

echo "Inserted record 2"

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name SourceSystems \
    --item '{
    "SystemId": {"N": "3"},
    "SystemName": {"S": "MobileApp"},
    "Description": {"S": "iOS and Android mobile applications"},
    "SystemType": {"S": "Application"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
}'

echo "Inserted record 3"

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name SourceSystems \
    --item '{
    "SystemId": {"N": "4"},
    "SystemName": {"S": "BackgroundJob"},
    "Description": {"S": "Scheduled background processing jobs"},
    "SystemType": {"S": "Service"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
}'

echo "All records inserted successfully!"