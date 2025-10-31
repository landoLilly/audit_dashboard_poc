# DynamoDB Stream to Webhook Lambda Function

This directory contains an AWS Lambda function that processes DynamoDB stream events and sends webhook notifications to the Phoenix application when records are inserted into the AuditEvents table.

## Configuration

The Lambda function uses the following environment variables:

- `WEBHOOK_URL`: URL of the webhook endpoint (default: `http://host.docker.internal:4000/api/webhook/dynamodb-stream`)
- `TABLE_NAME`: DynamoDB table name to monitor (default: `AuditEvents`)
- `WEBHOOK_TIMEOUT`: HTTP timeout in milliseconds (default: `10000`)
- `ENVIRONMENT`: Environment name (default: `dev`)

For local testing, the webhook URL uses `host.docker.internal:4000` to connect from the Docker container to your local Phoenix app.

## Function Behavior

The Lambda function:

1. **Filters Events**: Only processes `INSERT` events from the `AuditEvents` table
2. **Sends Webhooks**: Makes HTTP POST requests to the configured webhook URL
3. **Handles Errors**: Logs failures and continues processing other records
4. **Returns Status**: Provides detailed response about processing results

### Example Webhook Payload

```json
{
  "Records": [
    {
      "eventID": "1",
      "eventName": "INSERT",
      "eventSource": "aws:dynamodb",
      "eventSourceARN": "arn:aws:dynamodb:us-east-1:123456789012:table/AuditEvents/stream/2025-10-31T00:00:00.000",
      "dynamodb": {
        "Keys": {
          "AuditId": {"S": "audit-123-test"}
        },
        "NewImage": {
          "AuditId": {"S": "audit-123-test"},
          "EventTimestamp": {"S": "2025-10-31T10:30:00Z"},
          "UserId": {"S": "user-456"},
          "EventType": {"S": "LOGIN"},
          "Source": {"S": "web-app"},
          "Status": {"S": "SUCCESS"}
        }
      }
    }
  ]
}
```
