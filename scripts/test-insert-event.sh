#!/bin/bash

# Script to insert a test audit event via AWS CLI to simulate external systems adding events to DynamoDB

set -e

ENDPOINT_URL="--endpoint-url http://localhost:8000"
REGION="--region us-east-1"
TABLE_NAME="AuditEvents"

# Generate unique IDs and timestamp
AUDIT_ID="test-cli-$(date +%s)-$(jot -r 1 1000 9999)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CREATED_AT="$TIMESTAMP"
PARTITION_KEY=$(date -u +"%Y-%m")

# Calculate TTL (90 days from now)
TTL=$(($(date +%s) + 7776000))

echo "🚀 Inserting test audit event via AWS CLI..."
echo "   Audit ID: $AUDIT_ID"
echo "   Timestamp: $TIMESTAMP"

# Insert the audit event using aws dynamodb put-item
aws dynamodb put-item \
  --table-name "$TABLE_NAME" \
  --item '{
    "AuditId": {"S": "'$AUDIT_ID'"},
    "EventTimestamp": {"S": "'$TIMESTAMP'"},
    "CreatedAt": {"S": "'$CREATED_AT'"},
    "UserId": {"S": "cli-test-user"},
    "EventType": {"S": "authentication"},
    "Source": {"S": "aws_cli_test"},
    "Status": {"S": "SUCCESS"},
    "Action": {"S": "login"},
    "IpAddress": {"S": "192.168.1.100"},
    "Description": {"S": "Test login event inserted via AWS CLI"},
    "ResourceId": {"S": "resource-123"},
    "ResourceType": {"S": "user_account"},
    "SessionId": {"S": "session-$(date +%s)"},
    "UserAgent": {"S": "AWS-CLI-Test/1.0"},
    "PartitionKey": {"S": "'$PARTITION_KEY'"},
    "TTL": {"N": "'$TTL'"}
  }' \
  $ENDPOINT_URL \
  $REGION

echo "✅ Audit event inserted successfully!"
echo ""
echo "📊 Event details:"
echo "   ID: $AUDIT_ID"
echo "   Type: authentication"
echo "   User: cli-test-user"
echo "   Action: login"
echo "   Status: SUCCESS"
echo "   Timestamp: $TIMESTAMP"
echo ""
echo "💡 To verify the event was stored, run:"
echo "   aws dynamodb get-item --table-name AuditEvents --key '{\"AuditId\": {\"S\": \"$AUDIT_ID\"}}' $ENDPOINT_URL $REGION"