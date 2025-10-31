#!/bin/bash

ENDPOINT="http://localhost:8000"

# Insert record 1
aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name AdminAccessLog \
    --item '{
        "AccessId": {"S": "acc_550e8400-e29b-41d4-a716-446655440101"},
        "AdminUserId": {"S": "admin_john"},
        "AdminEmail": {"S": "john.admin@company.com"},
        "AdminUserAction": {"S": "admin_john#ViewAuditLogs"},
        "AccessTimestamp": {"S": "2024-01-15T16:00:00.000Z"},
        "Action": {"S": "ViewAuditLogs"},
        "Details": {"S": "{\"filters\":{\"eventType\":\"UserLogin\"},\"pageSize\":50,\"page\":1}"},
        "ResourceId": {"S": "/audit-logs"},
        "UserAgent": {"S": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"},
        "ResultCount": {"N": "25"},
        "IPAddress": {"S": "172.16.0.10"}
    }'

echo "Inserted record 1"

# Insert record 2
aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name AdminAccessLog \
    --item '{
        "AccessId": {"S": "acc_550e8400-e29b-41d4-a716-446655440105"},
        "AdminUserId": {"S": "admin_jane"},
        "AdminEmail": {"S": "jane.admin@company.com"},
        "AdminUserAction": {"S": "admin_jane#SearchAuditLogs"},
        "AccessTimestamp": {"S": "2024-01-15T17:30:00.000Z"},
        "Action": {"S": "SearchAuditLogs"},
        "Details": {"S": "{\"searchTerm\":\"failed login\",\"filters\":{},\"pageSize\":50}"},
        "ResourceId": {"S": "/audit-logs/search"},
        "UserAgent": {"S": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"},
        "ResultCount": {"N": "12"},
        "IPAddress": {"S": "172.16.0.15"}
    }'

echo "Inserted record 2"

# Insert record 3
aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name AdminAccessLog \
    --item '{
        "AccessId": {"S": "acc_550e8400-e29b-41d4-a716-446655440102"},
        "AdminUserId": {"S": "admin_jane"},
        "AdminEmail": {"S": "jane.admin@company.com"},
        "AdminUserAction": {"S": "admin_jane#ExportAuditLogs"},
        "AccessTimestamp": {"S": "2024-01-15T16:30:00.000Z"},
        "Action": {"S": "ExportAuditLogs"},
        "Details": {"S": "{\"format\":\"CSV\",\"dateRange\":\"2024-01-01 to 2024-01-15\",\"recordCount\":1523}"},
        "ResourceId": {"S": "/exports/report_2024_01"},
        "UserAgent": {"S": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"},
        "ResultCount": {"N": "1523"},
        "IPAddress": {"S": "172.16.0.15"}
    }'

echo "Inserted record 3"

# Insert record 4
aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name AdminAccessLog \
    --item '{
        "AccessId": {"S": "acc_550e8400-e29b-41d4-a716-446655440103"},
        "AdminUserId": {"S": "admin_john"},
        "AdminEmail": {"S": "john.admin@company.com"},
        "AdminUserAction": {"S": "admin_john#ViewAuditDetails"},
        "AccessTimestamp": {"S": "2024-01-15T17:00:00.000Z"},
        "Action": {"S": "ViewAuditDetails"},
        "Details": {"S": "{\"auditId\":\"550e8400-e29b-41d4-a716-446655440001\",\"eventType\":\"UserLogin\"}"},
        "ResourceId": {"S": "/audit-logs/550e8400-e29b-41d4-a716-446655440001"},
        "UserAgent": {"S": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"},
        "ResultCount": {"N": "1"},
        "IPAddress": {"S": "172.16.0.10"}
    }'

echo "Inserted record 4"

# Insert record 5
aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name AdminAccessLog \
    --item '{
        "AccessId": {"S": "acc_550e8400-e29b-41d4-a716-446655440104"},
        "AdminUserId": {"S": "admin_john"},
        "AdminEmail": {"S": "john.admin@company.com"},
        "AdminUserAction": {"S": "admin_john#FilterByUser"},
        "AccessTimestamp": {"S": "2024-01-15T17:15:00.000Z"},
        "Action": {"S": "FilterByUser"},
        "Details": {"S": "{\"filters\":{\"userId\":\"user123\",\"dateRange\":\"last7days\"},\"pageSize\":100}"},
        "ResourceId": {"S": "/audit-logs?userId=user123"},
        "UserAgent": {"S": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"},
        "ResultCount": {"N": "47"},
        "IPAddress": {"S": "172.16.0.10"}
    }'

echo "Inserted record 5"

echo "All records inserted successfully!"