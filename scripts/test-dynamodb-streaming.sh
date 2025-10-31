#!/bin/bash

# Test script for DynamoDB streaming functionality
# This script demonstrates how to test the streaming setup locally

set -e

PHOENIX_URL="http://localhost:4000"
WEBHOOK_ENDPOINT="$PHOENIX_URL/api/webhook/dynamodb-stream"

echo "=== Testing DynamoDB Streaming Setup ==="

# Function to test webhook endpoint
test_webhook() {
    echo "Testing webhook endpoint..."
    
    # Test with valid DynamoDB stream payload
    echo "Sending test INSERT event..."
    curl -X POST "$WEBHOOK_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d '{
            "Records": [
                {
                    "eventName": "INSERT",
                    "dynamodb": {
                        "Keys": {
                            "AuditId": {"S": "test-webhook-audit-id"}
                        },
                        "NewImage": {
                            "AuditId": {"S": "test-webhook-audit-id"},
                            "EventType": {"S": "authentication"},
                            "UserId": {"S": "webhook-test-user"},
                            "EventTimestamp": {"S": "2024-10-28T15:30:00Z"},
                            "IpAddress": {"S": "192.168.1.100"},
                            "Action": {"S": "login"},
                            "Status": {"S": "SUCCESS"}
                        }
                    }
                }
            ]
        }' \
        --silent --show-error
    
    echo -e "\n"
    
    # Test with UPDATE event
    echo "Sending test UPDATE event..."
    curl -X POST "$WEBHOOK_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d '{
            "Records": [
                {
                    "eventName": "MODIFY",
                    "dynamodb": {
                        "Keys": {
                            "AuditId": {"S": "test-webhook-audit-id"}
                        },
                        "NewImage": {
                            "AuditId": {"S": "test-webhook-audit-id"},
                            "EventType": {"S": "authentication"},
                            "UserId": {"S": "webhook-test-user"},
                            "EventTimestamp": {"S": "2024-10-28T15:31:00Z"},
                            "IpAddress": {"S": "192.168.1.100"},
                            "Action": {"S": "logout"},
                            "Status": {"S": "SUCCESS"}
                        }
                    }
                }
            ]
        }' \
        --silent --show-error
    
    echo -e "\n"
    
    # Test with DELETE event
    echo "Sending test DELETE event..."
    curl -X POST "$WEBHOOK_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d '{
            "Records": [
                {
                    "eventName": "REMOVE",
                    "dynamodb": {
                        "Keys": {
                            "AuditId": {"S": "test-webhook-audit-id"}
                        }
                    }
                }
            ]
        }' \
        --silent --show-error
    
    echo -e "\n"
}

# Function to create a real audit event in DynamoDB
create_real_audit_event() {
    echo "Creating real audit event in DynamoDB..."
    
    # Start an IEx session and create an audit event
    iex -S mix -e '
        # Create a new audit event
        attrs = %{
            event_type: "test_streaming",
            user_id: "streaming-test-user",
            source: "test_script",
            status: "SUCCESS",
            action: "test_stream_functionality",
            ip_address: "127.0.0.1",
            description: "Testing DynamoDB streaming functionality"
        }
        
        case AuditDashboardPoc.AuditEvents.create_audit_event(attrs) do
            {:ok, event} ->
                IO.puts("✅ Created audit event: #{event.id}")
            {:error, reason} ->
                IO.puts("❌ Failed to create audit event: #{inspect(reason)}")
        end
        
        # Give the system a moment to process
        Process.sleep(1000)
        
        System.halt(0)
    '
}

# Function to check if Phoenix app is running
check_phoenix_running() {
    echo "Checking if Phoenix app is running..."
    
    if curl -s "$PHOENIX_URL" > /dev/null; then
        echo "✅ Phoenix app is running at $PHOENIX_URL"
        return 0
    else
        echo "❌ Phoenix app is not running at $PHOENIX_URL"
        echo "Please start the Phoenix app with: mix phx.server"
        return 1
    fi
}

# Function to check DynamoDB connection
check_dynamodb() {
    echo "Checking DynamoDB connection..."
    
    if aws dynamodb list-tables --endpoint-url http://localhost:8000 --region us-east-1 > /dev/null 2>&1; then
        echo "✅ DynamoDB is running locally"
        
        # Check if AuditEvents table exists
        if aws dynamodb describe-table --table-name AuditEvents --endpoint-url http://localhost:8000 --region us-east-1 > /dev/null 2>&1; then
            echo "✅ AuditEvents table exists"
        else
            echo "❌ AuditEvents table not found"
            echo "Please create the table with: ./scripts/audit-events-table-create.sh"
            return 1
        fi
    else
        echo "❌ DynamoDB is not running locally"
        echo "Please start DynamoDB local on port 8000"
        return 1
    fi
}

# Main execution
main() {
    echo "Prerequisites check:"
    echo "==================="
    
    if ! check_phoenix_running; then
        exit 1
    fi
    
    if ! check_dynamodb; then
        exit 1
    fi
    
    echo -e "\n"
    echo "Running tests:"
    echo "=============="
    
    # Test webhook functionality
    test_webhook
    
    echo "Testing real DynamoDB event creation:"
    echo "===================================="
    
    # Create a real audit event to test end-to-end
    create_real_audit_event
    
    echo -e "\n"
    echo "✅ All tests completed!"
    echo ""
    echo "Next steps:"
    echo "1. Check your Phoenix app dashboard at $PHOENIX_URL/dashboard"
    echo "2. Look for the test events in the audit events table"
    echo "3. Check the Phoenix logs for streaming events"
    echo ""
}

# Run the main function
main "$@"