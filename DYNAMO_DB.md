#TODO: Script this out

To enable real-time UI updates with DynamoDB, we can use DynamoDB Streams to capture changes to the data in the AuditEvents table. When a new record is inserted into the table, a corresponding event is generated in the stream. We can then set up an AWS Lambda function to process these stream events and send notifications to the Phoenix application via a webhook.

The following steps outline how to set up this integration using LocalStack for local development and testing:

## Prerequisites
- Ensure you have LocalStack installed and running for local AWS service emulation.
- Ensure you have the AWS CLI installed

## Steps to Set Up DynamoDB Streams with Lambda and Webhook
1. **Create a DynamoDB Table with Streams Enabled**
   - Create the `AuditEvents` table in DynamoDB with streams enabled by running the `audit-events-create-table-localstack.sh` script.
  
  ```bash
   ./scripts/audit-events-create-table-localstack.sh
   ```

2. **Seed the Table with Initial Data**
    - Insert initial data into the `AuditEvents` table using the `audit-events-bulk-insert-localstack.sh` script.

  ```bash
   ./scripts/audit-events-bulk-insert-localstack.sh
   ```

3. **Create the Lambda Function**
    - Create a Lambda function that will process the DynamoDB stream events. The function will extract the new records and send them to the Phoenix application's webhook endpoint.

    ```bash
      aws lambda create-function \
        --endpoint-url http://localhost:4566 \
        --region us-east-1 \
        --function-name processDynamoDbRecords \
        --zip-file fileb://lambda/function.zip \
        --handler index.handler \
        --timeout 50 \
        --runtime nodejs16.x \
        --role arn:aws:iam::000000000000:role/lambda-role
    ```

4. **Set Up the Event Source Mapping**
    - First get the stream arn for the `AuditEvents` table:

    ```bash
    aws dynamodb describe-table \
        --table-name AuditEvents \
        --endpoint-url http://localhost:4566 \
        --query "Table.LatestStreamArn" \
        --output text
    ```
    
    - Link the DynamoDB stream to the Lambda function so that the function is triggered whenever there are new records in the stream:

    ```bash
      aws lambda create-event-source-mapping \
        --endpoint-url http://localhost:4566 \
        --region us-east-1 \
        --function-name processDynamoDbRecords \
        --event-source <INSERT STREAM ARN FROM PREVIOUS STEP HERE> \
        --batch-size 10 \
        --starting-position LATEST
    ```

5. **Test the Setup**
    - Start the Phoenix application and open a web browser http://localhost:4000/dashboard to view the audit dashboard:
    
    ```bash
      mix phx.server
    ```

    - Insert a new record into the `AuditEvents` table to trigger the Lambda function and see the audit dashboard update in real-time:

    ```bash
      scripts/test-insert-event-localstack.sh
    ```

