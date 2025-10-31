#!/bin/bash

set -e

ENDPOINT="http://localhost:4566"
# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TABLE_NAME="AuditEvents"
REGION="us-east-1"
TOTAL_RECORDS=500
BATCH_SIZE=25

# Arrays for random data
USERS=("user001" "user002" "user003" "user004" "user005" "user006" "user007" "user008" "user009" "user010" "admin001" "admin002" "admin003")
EVENT_TYPES=("USER_LOGIN" "USER_LOGOUT" "DATA_ACCESS" "DATA_MODIFY" "DATA_DELETE" "DATA_CREATE" "PERMISSION_CHANGE" "SETTINGS_UPDATE" "PASSWORD_CHANGE" "PROFILE_UPDATE")
SOURCES=("WEB_APP" "MOBILE_APP" "API_GATEWAY" "ADMIN_PORTAL" "BATCH_JOB" "INTEGRATION_SERVICE")
STATUSES=("SUCCESS" "SUCCESS" "SUCCESS" "SUCCESS" "FAILURE")  # 80% success rate
ACTIONS=("CREATE" "READ" "UPDATE" "DELETE" "LOGIN" "LOGOUT" "EXECUTE" "EXPORT" "IMPORT")
RESOURCE_TYPES=("USER_ACCOUNT" "DOCUMENT" "REPORT" "USER_PROFILE" "CONFIGURATION" "DATABASE" "API_KEY" "USER_ROLE")
IP_RANGES=("192.168.1" "192.168.2" "10.0.1" "10.0.2" "172.16.0" "203.0.113")

# Function to get random element
get_random() {
    local array=("$@")
    echo "${array[$((RANDOM % ${#array[@]}))]}"
}

# Function to generate UUID
generate_uuid() {
    cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen | tr '[:upper:]' '[:lower:]'
}

# Function to generate timestamp (random in last 30 days)
generate_timestamp() {
    local days_ago=$((RANDOM % 30))
    local hours_ago=$((RANDOM % 24))
    local minutes_ago=$((RANDOM % 60))
    local seconds=$(( $(date +%s) - (days_ago * 86400) - (hours_ago * 3600) - (minutes_ago * 60) ))
    date -u -d "@$seconds" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || date -u -r $seconds +"%Y-%m-%dT%H:%M:%S.000Z"
}

# Function to get partition key from timestamp
get_partition_key() {
    echo "${1:0:7}"  # Extract YYYY-MM
}

# Function to calculate TTL (90 days from timestamp)
calculate_ttl() {
    local timestamp=$1
    local epoch=$(date -d "$timestamp" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S.000Z" "$timestamp" +%s)
    echo $((epoch + 7776000))  # +90 days
}

# Function to generate IP address
generate_ip() {
    local range=$(get_random "${IP_RANGES[@]}")
    echo "${range}.$((RANDOM % 255))"
}

# Function to create batch file
create_batch_file() {
    local batch_num=$1
    local filename="batch_${batch_num}.json"
    local items_in_batch=$2
    
    echo "{" > "$filename"
    echo "  \"$TABLE_NAME\": [" >> "$filename"
    
    for ((i=1; i<=items_in_batch; i++)); do
        local audit_id=$(generate_uuid)
        local timestamp=$(generate_timestamp)
        local user_id=$(get_random "${USERS[@]}")
        local event_type=$(get_random "${EVENT_TYPES[@]}")
        local source=$(get_random "${SOURCES[@]}")
        local status=$(get_random "${STATUSES[@]}")
        local action=$(get_random "${ACTIONS[@]}")
        local resource_type=$(get_random "${RESOURCE_TYPES[@]}")
        local session_id="sess_$(generate_uuid | cut -d'-' -f1)"
        local partition_key=$(get_partition_key "$timestamp")
        local ttl=$(calculate_ttl "$timestamp")
        local ip=$(generate_ip)
        # local resource_id="${resource_type,,}_$(( RANDOM % 10000 ))"
        local resource_id="$(echo $resource_type | tr '[:upper:]' '[:lower:]')_$(( RANDOM % 10000 ))"
        
        cat >> "$filename" << EOF
    {
      "PutRequest": {
        "Item": {
          "AuditId": {"S": "$audit_id"},
          "EventTimestamp": {"S": "$timestamp"},
          "UserId": {"S": "$user_id"},
          "EventType": {"S": "$event_type"},
          "Source": {"S": "$source"},
          "Status": {"S": "$status"},
          "SessionId": {"S": "$session_id"},
          "Action": {"S": "$action"},
          "ResourceType": {"S": "$resource_type"},
          "ResourceId": {"S": "$resource_id"},
          "PartitionKey": {"S": "$partition_key"},
          "TTL": {"N": "$ttl"},
          "IpAddress": {"S": "$ip"},
          "UserAgent": {"S": "Mozilla/5.0 (compatible; AuditSystem/1.0)"},
          "Description": {"S": "$event_type event by $user_id from $source"},
          "CreatedAt": {"S": "$timestamp"}
        }
      }
    }$([ $i -lt $items_in_batch ] && echo "," || echo "")
EOF
    done
    
    echo "  ]" >> "$filename"
    echo "}" >> "$filename"
    
    echo "$filename"
}

# Main execution
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Bulk Insert Audit Events                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Table: $TABLE_NAME"
echo -e "  Region: $REGION"
echo -e "  Total Records: $TOTAL_RECORDS"
echo -e "  Batch Size: $BATCH_SIZE\n"

# Calculate number of batches
batch_count=$(( (TOTAL_RECORDS + BATCH_SIZE - 1) / BATCH_SIZE ))

echo -e "${GREEN}Starting bulk insert of $TOTAL_RECORDS records in $batch_count batches...${NC}\n"

inserted_count=0
failed_count=0

for ((batch=1; batch<=batch_count; batch++)); do
    remaining=$((TOTAL_RECORDS - inserted_count))
    items_in_batch=$((remaining < BATCH_SIZE ? remaining : BATCH_SIZE))
    
    echo -e "${BLUE}Batch $batch/$batch_count:${NC} Creating batch file with $items_in_batch items..."
    
    batch_file=$(create_batch_file $batch $items_in_batch)
    
    echo "  Inserting batch..."
    
    if aws dynamodb batch-write-item \
        --request-items "file://$batch_file" \
        --region $REGION \
        --endpoint-url $ENDPOINT \
        --return-consumed-capacity TOTAL > /dev/null 2>&1; then
        
        inserted_count=$((inserted_count + items_in_batch))
        echo -e "  ${GREEN}✓ Success${NC} ($inserted_count/$TOTAL_RECORDS records inserted)"
        rm "$batch_file"
    else
        failed_count=$((failed_count + items_in_batch))
        echo -e "  ${RED}✗ Failed${NC}"
        echo "  Batch file saved: $batch_file"
    fi
    
    # Small delay to avoid throttling
    sleep 0.5
done

echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Bulk Insert Summary                                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}✓ Successfully inserted: $inserted_count records${NC}"
[ $failed_count -gt 0 ] && echo -e "${RED}✗ Failed to insert: $failed_count records${NC}"

echo -e "\n${YELLOW}Verifying table item count...${NC}"
sleep 2  # Wait for eventual consistency

item_count=$(aws dynamodb describe-table \
    --table-name $TABLE_NAME \
    --region $REGION \
    --query 'Table.ItemCount' \
    --endpoint-url $ENDPOINT \
    --output text)

echo -e "Current item count: ${GREEN}$item_count${NC}\n"

echo -e "${YELLOW}Sample Data Statistics:${NC}"
echo -e "  Users: ${#USERS[@]} different users"
echo -e "  Event Types: ${#EVENT_TYPES[@]} types"
echo -e "  Sources: ${#SOURCES[@]} sources"
echo -e "  Date Range: Last 30 days"
echo -e "  Success Rate: ~80%\n"

echo -e "${GREEN}Bulk insert completed!${NC}\n"
