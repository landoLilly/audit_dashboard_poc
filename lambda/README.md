# DynamoDB Stream to Webhook Lambda Function

This directory contains an AWS Lambda function that processes DynamoDB stream events and sends webhook notifications to the Phoenix application when records are inserted into the AuditEvents table.

## Structure

```
lambda/
├── index.js                           # Main Lambda function code
├── package.json                       # Node.js dependencies
├── test-events/                       # Test event files for local testing
│   ├── dynamodb-insert.json          # Single INSERT event
│   ├── dynamodb-modify.json          # Single MODIFY event (won't trigger webhook)
│   └── multiple-inserts.json         # Multiple INSERT events
template.yaml                         # SAM template for local testing
start-sam-local.sh                    # Script to start SAM local environment
test-lambda.sh                        # Script to test the Lambda function
```

## Prerequisites

1. **AWS SAM CLI** - [Install SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
2. **Docker** - Required for SAM local testing
3. **Node.js** - For Lambda function dependencies
4. **jq** - For JSON processing in scripts (optional but recommended)

## Local Testing Setup

### 1. Install Dependencies

```bash
cd lambda
npm install
```

### 2. Build the SAM Application

```bash
# From the project root
sam build
```

### 3. Start Your Phoenix Application

Make sure your Phoenix application is running on port 4000:

```bash
mix phx.server
```

### 4. Test the Lambda Function

#### Option A: Quick Test with Default Event

```bash
./test-lambda.sh
```

#### Option B: Test with Specific Event

```bash
# Test with single INSERT event
./test-lambda.sh --event lambda/test-events/dynamodb-insert.json

# Test with multiple INSERT events
./test-lambda.sh --event lambda/test-events/multiple-inserts.json

# Test with MODIFY event (should not trigger webhook)
./test-lambda.sh --event lambda/test-events/dynamodb-modify.json
```

#### Option C: Test with Verbose Output

```bash
./test-lambda.sh --verbose
```

#### Option D: Direct SAM Invoke

```bash
sam local invoke ProcessDynamoDBRecordsFunction -e lambda/test-events/dynamodb-insert.json
```

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

## Testing Different Scenarios

### 1. Successful Webhook Call

```bash
# Make sure Phoenix app is running, then:
./test-lambda.sh --event lambda/test-events/dynamodb-insert.json --verbose
```

Expected output:
- Lambda function processes the INSERT event
- Webhook call is made to Phoenix app
- Phoenix app logs show webhook received
- Lambda returns success status

### 2. Filtered Events (No Webhook)

```bash
# Test with MODIFY event (should be filtered out):
./test-lambda.sh --event lambda/test-events/dynamodb-modify.json --verbose
```

Expected output:
- Lambda function filters out the MODIFY event
- No webhook call is made
- Lambda returns "No relevant records to process"

### 3. Webhook Failure

```bash
# Stop Phoenix app, then:
./test-lambda.sh --event lambda/test-events/dynamodb-insert.json --verbose
```

Expected output:
- Lambda function processes the INSERT event
- Webhook call fails (connection refused)
- Lambda logs the failure but continues processing

### 4. Multiple Records

```bash
./test-lambda.sh --event lambda/test-events/multiple-inserts.json --verbose
```

Expected output:
- Lambda function processes multiple INSERT events
- Multiple webhook calls are made
- Lambda returns statistics about success/failure

## Deployment to AWS

When ready to deploy to AWS:

1. Update the webhook URL in `template.yaml` to point to your production Phoenix app
2. Deploy using SAM:

```bash
sam deploy --guided
```

Or use CloudFormation directly with the provided templates.

## Troubleshooting

### Common Issues

1. **"Docker not running"**
   - Start Docker Desktop
   - Verify with: `docker info`

2. **"SAM CLI not found"**
   - Install SAM CLI following [official instructions](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)

3. **Webhook connection fails**
   - Ensure Phoenix app is running on port 4000
   - Check that the webhook URL uses `host.docker.internal` for local testing
   - Verify the endpoint exists: `curl -X POST http://localhost:4000/api/webhook/dynamodb-stream`

4. **"Function not found"**
   - Run `sam build` first
   - Check that `template.yaml` is in the project root

### Debugging

1. **View Lambda Logs**:
   ```bash
   ./test-lambda.sh --verbose
   ```

2. **Check Phoenix Logs**:
   Look at your Phoenix app terminal for incoming webhook requests

3. **Test Webhook Endpoint Directly**:
   ```bash
   curl -X POST http://localhost:4000/api/webhook/dynamodb-stream \
     -H "Content-Type: application/json" \
     -d @lambda/test-events/dynamodb-insert.json
   ```

4. **Inspect Event Files**:
   ```bash
   cat lambda/test-events/dynamodb-insert.json | jq .
   ```

## Next Steps

1. Test the integration end-to-end with your Phoenix application
2. Customize the event filtering logic if needed
3. Add additional error handling or retry logic
4. Deploy to AWS when ready for production use