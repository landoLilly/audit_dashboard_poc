#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FUNCTION_NAME="ProcessDynamoDBRecordsFunction"
LAMBDA_PORT=${LAMBDA_PORT:-3001}
DEFAULT_EVENT="lambda/test-events/dynamodb-insert.json"

# Parse command line arguments
EVENT_FILE="$DEFAULT_EVENT"
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --event|-e)
      EVENT_FILE="$2"
      shift 2
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "This script calls a Lambda function running in SAM Local."
      echo "Make sure to start SAM Local first with: sam local start-lambda --template lambda/template.yaml --port 3001"
      echo ""
      echo "Options:"
      echo "  -e, --event FILE     Event file to use (default: $DEFAULT_EVENT)"
      echo "  -v, --verbose        Show verbose output"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Available test events:"
      echo "  lambda/test-events/dynamodb-insert.json     - Single INSERT event"
      echo "  lambda/test-events/dynamodb-modify.json     - Single MODIFY event"
      echo "  lambda/test-events/multiple-inserts.json    - Multiple INSERT events"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Calling Lambda Function in SAM Local                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if event file exists
if [ ! -f "$EVENT_FILE" ]; then
    echo -e "${RED}❌ Event file not found: $EVENT_FILE${NC}"
    exit 1
fi

# Check if SAM Local is running
LAMBDA_URL="http://localhost:$LAMBDA_PORT/2015-03-31/functions/$FUNCTION_NAME/invocations"
if ! curl -s --connect-timeout 2 "$LAMBDA_URL" > /dev/null 2>&1; then
    echo -e "${RED}❌ SAM Local Lambda runtime not running on port $LAMBDA_PORT${NC}"
    echo -e "${YELLOW}💡 Start it first with:${NC}"
    echo -e "   ${GREEN}sam local start-lambda --template lambda/template.yaml --port $LAMBDA_PORT${NC}"
    echo ""
    echo -e "${YELLOW}💡 Or use the convenience script:${NC}"
    echo -e "   ${GREEN}./scripts/start-sam-local.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Function: ${GREEN}$FUNCTION_NAME${NC}"
echo -e "  Event File: ${GREEN}$EVENT_FILE${NC}"
echo -e "  Lambda URL: ${GREEN}$LAMBDA_URL${NC}"
echo -e "  Verbose: ${GREEN}$VERBOSE${NC}"
echo ""

# Show event content if verbose
if [ "$VERBOSE" = true ]; then
    echo -e "${YELLOW}📄 Event Content:${NC}"
    cat "$EVENT_FILE" | jq . || cat "$EVENT_FILE"
    echo ""
fi

echo -e "${YELLOW}📡 Calling Lambda function...${NC}"

# Make the HTTP request
if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Making POST request to: $LAMBDA_URL${NC}"
    echo ""
fi

# Create temporary files for response and http code
response_file=$(mktemp)
http_code_file=$(mktemp)

# Make the request and capture both response and HTTP code
curl -s -w "%{http_code}" -X POST \
    "$LAMBDA_URL" \
    -H "Content-Type: application/json" \
    -d @"$EVENT_FILE" \
    -o "$response_file" > "$http_code_file"

# Read the results
http_code=$(cat "$http_code_file")
response_body=$(cat "$response_file")

# Clean up temp files
rm -f "$response_file" "$http_code_file"

echo -e "${YELLOW}📋 Response:${NC}"
if command -v jq &> /dev/null && [ -n "$response_body" ]; then
    echo "$response_body" | jq . 2>/dev/null || echo "$response_body"
else
    echo "$response_body"
fi

echo ""
if [ "$http_code" -eq 200 ]; then
    echo -e "${GREEN}✅ Lambda function call completed successfully! (HTTP $http_code)${NC}"
else
    echo -e "${RED}❌ Lambda function call failed with HTTP $http_code${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  - Make sure your Phoenix app is running on port 4000"
echo -e "  - Check the Phoenix app logs to see if webhook was received"
echo -e "  - Use --verbose flag to see request details"