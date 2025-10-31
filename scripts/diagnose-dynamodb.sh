#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TABLE_NAME="AuditEvents"
REGION="local"  # MUST be "local" for your DynamoDB Local setup
ENDPOINT_URL="http://localhost:8001"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Creating DynamoDB AuditEvents Table (Local)              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Table Name: ${GREEN}$TABLE_NAME${NC}"
echo -e "  Region: ${GREEN}$REGION${NC}"
echo -e "  Endpoint: ${GREEN}$ENDPOINT_URL${NC}\n"

# Check if table already exists
echo -e "${YELLOW}Checking existing tables...${NC}"
#aws dynamodb list-tables --endpoint-url $ENDPOINT_URL --output table

TABLE_EXISTS=$(aws dynamodb list-tables \
    --endpoint-url $ENDPOINT_URL \
    --output json 2>/dev/null | grep -o "\"$TABLE_NAME\"" || echo "")

if [ ! -z "$TABLE_EXISTS" ]; then
    echo -e "${YELLOW}Table '$TABLE_NAME' already exists!${NC}"
    read -p "Do you want to delete and recreate it? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo -e "${RED}Deleting existing table...${NC}"
        aws dynamodb delete-table \
            --table-name $TABLE_NAME \
            --endpoint-url $ENDPOINT_URL \
            --region $REGION
        echo "Waiting 2 seconds..."
        sleep 2
        echo -e "${GREEN}Table deleted${NC}\n"
    else
        echo -e "${YELLOW}Exiting without changes${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}Creating table with 6 GSIs...${NC}\n"

aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url $ENDPOINT_URL \
  --attribute-definitions \
    AttributeName=AuditId,AttributeType=S \
    AttributeName=EventTimestamp,AttributeType=S \
    AttributeName=UserId,AttributeType=S \
    AttributeName=EventType,AttributeType=S \
    AttributeName=Source,AttributeType=S \
    AttributeName=Status,AttributeType=S \
    AttributeName=SessionId,AttributeType=S \
    AttributeName=PartitionKey,AttributeType=S \
  --key-schema \
    AttributeName=AuditId,KeyType=HASH \
  --global-secondary-indexes \
    '[
      {
        "IndexName": "GSI1-UserId-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"UserId","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI2-EventType-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"EventType","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI3-Source-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"Source","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI4-Status-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"Status","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI5-PartitionKey-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"PartitionKey","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI6-SessionId-EventTimestamp",
        "KeySchema": [
          {"AttributeName":"SessionId","KeyType":"HASH"},
          {"AttributeName":"EventTimestamp","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      }
    ]' \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE \
  --tags Key=Environment,Value=Development Key=Application,Value=AuditSystem

  if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Table created successfully!${NC}\n"
    
    sleep 1
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Table Details                                             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    aws dynamodb describe-table \
      --table-name $TABLE_NAME \
      --endpoint-url $ENDPOINT_URL \
      --query 'Table.{Name:TableName,Status:TableStatus,ItemCount:ItemCount,GSIs:GlobalSecondaryIndexes[*].IndexName}' \
      --output table
    
    echo -e "\n${GREEN}✓ Base Table: AuditEvents${NC}"
    echo -e "${GREEN}✓ GSI1: UserId-EventTimestamp${NC}"
    echo -e "${GREEN}✓ GSI2: EventType-EventTimestamp${NC}"
    echo -e "${GREEN}✓ GSI3: Source-EventTimestamp${NC}"
    echo -e "${GREEN}✓ GSI4: Status-EventTimestamp${NC}"
    echo -e "${GREEN}✓ GSI5: PartitionKey-EventTimestamp${NC}"
    echo -e "${GREEN}✓ GSI6: SessionId-EventTimestamp${NC}"
    echo -e "\n${YELLOW}Note: DynamoDB Local does not support TTL and PITR${NC}\n"
else
    echo -e "\n${RED}✗ Failed to create table${NC}"
    exit 1
fi