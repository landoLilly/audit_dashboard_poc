#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Starting SAM Local Environment for Lambda Testing          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo -e "${RED}❌ SAM CLI is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}   Install instructions: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Build the SAM application
echo -e "${YELLOW}🔨 Building SAM application...${NC}"
sam build --template lambda/template.yaml

echo -e "${YELLOW}🚀 Starting SAM local environment...${NC}"
echo -e "${BLUE}This will start:${NC}"
echo -e "  - Lambda function locally"
echo -e "  - DynamoDB Local (if not already running)"
echo -e "  - API Gateway Local (if needed)"
echo ""

# Start SAM local with DynamoDB
sam local start-lambda --docker-network host --template lambda/template.yaml &
SAM_PID=$!

echo -e "${GREEN}✅ SAM Local started with PID: $SAM_PID${NC}"
echo ""
echo -e "${YELLOW}📝 To test the function:${NC}"
echo -e "1. Make sure your Phoenix app is running on port 4000"
echo -e "2. Use the lambda/test-lambda.sh script to invoke the function with test data"
echo -e "3. Or use: sam local invoke ProcessDynamoDBRecordsFunction -e lambda/test-events/dynamodb-insert.json --template lambda/template.yaml"
echo ""
echo -e "${YELLOW}🛑 To stop SAM Local, press Ctrl+C or run: kill $SAM_PID${NC}"

# Wait for interrupt
trap "echo -e '\n${YELLOW}Stopping SAM Local...${NC}'; kill $SAM_PID 2>/dev/null; exit 0" INT

wait $SAM_PID