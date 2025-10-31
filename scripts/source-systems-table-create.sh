#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TABLE_NAME="SourceSystems"
ENDPOINT_URL="http://localhost:8000"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Creating DynamoDB SourceSystems Table (Local)             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Table Name: ${GREEN}$TABLE_NAME${NC}"
echo -e "  Endpoint: ${GREEN}$ENDPOINT_URL${NC}\n"

# Check if table already exists
echo -e "${YELLOW}Checking existing tables...${NC}"
aws dynamodb list-tables --endpoint-url $ENDPOINT_URL --output table

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
        echo "Waiting 2 seconds..."
        sleep 2
        echo -e "${GREEN}Table deleted${NC}\n"
    else
        echo -e "${YELLOW}Exiting without changes${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}Creating table with 2 GSIs...${NC}\n"

aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --endpoint-url $ENDPOINT_URL \
  --billing-mode PAY_PER_REQUEST \
  --attribute-definitions \
    AttributeName=SystemId,AttributeType=N \
    AttributeName=SystemName,AttributeType=S \
    AttributeName=SystemType,AttributeType=S \
  --key-schema \
    AttributeName=SystemId,KeyType=HASH \
  --global-secondary-indexes \
    "[
      {
        \"IndexName\": \"GSI1-SystemName\",
        \"KeySchema\": [
          {\"AttributeName\": \"SystemName\", \"KeyType\": \"HASH\"}
        ],
        \"Projection\": {
          \"ProjectionType\": \"ALL\"
        }
      },
      {
        \"IndexName\": \"GSI2-SystemType\",
        \"KeySchema\": [
          {\"AttributeName\": \"SystemType\", \"KeyType\": \"HASH\"}
        ],
        \"Projection\": {
          \"ProjectionType\": \"ALL\"
        }
      }
    ]" \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE \
  --tags Key=Environment,Value=Development Key=Application,Value=AuditSystem

  echo "Table creation initiated. Waiting for table to become ACTIVE..."
  # Wait for table to become ACTIVE
  aws dynamodb wait table-exists --table-name $TABLE_NAME --endpoint-url $ENDPOINT_URL

  echo "Table is now ACTIVE."
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

    echo -e "\n${GREEN}✓ Base Table: SourceSystems${NC}"
    echo -e "${GREEN}✓ GSI1: GSI1-SystemName${NC}"
    echo -e "${GREEN}✓ GSI2: GSI2-SystemType${NC}"
    echo -e "\n${YELLOW}Note: DynamoDB Local does not support TTL and PITR${NC}\n"
else
    echo -e "\n${RED}✗ Failed to create table${NC}"
    exit 1
fi