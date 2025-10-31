#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

FUNCTION_NAME="ProcessDynamoDBRecordsFunction"
DEFAULT_EVENT="lambda/test-events/dynamodb-insert.json"
TEMPLATE_PATH="lambda/template.yaml"

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
      echo "Options:"
      echo "  -e, --event FILE     Event file to use (default: $DEFAULT_EVENT)"
      echo "  -v, --verbose        Show verbose output"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Available test events:"
      echo "  test-events/dynamodb-insert.json     - Single INSERT event"
      echo "  test-events/dynamodb-modify.json     - Single MODIFY event"
      echo "  test-events/multiple-inserts.json    - Multiple INSERT events"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Testing Lambda Function with SAM Local                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if event file exists
if [ ! -f "$EVENT_FILE" ]; then
    echo -e "${RED}❌ Event file not found: $EVENT_FILE${NC}"
    exit 1
fi

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo -e "${RED}❌ SAM CLI is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Function: ${GREEN}$FUNCTION_NAME${NC}"
echo -e "  Event File: ${GREEN}$EVENT_FILE${NC}"
echo -e "  Verbose: ${GREEN}$VERBOSE${NC}"
echo ""

# Show event content if verbose
if [ "$VERBOSE" = true ]; then
    echo -e "${YELLOW}📄 Event Content:${NC}"
    cat "$EVENT_FILE" | jq .
    echo ""
fi

# Check if the function has been built
if [ ! -d ".aws-sam" ]; then
    echo -e "${YELLOW}🔨 Building SAM application first...${NC}"
    sam build --template "$TEMPLATE_PATH"
    echo ""
fi

echo -e "${YELLOW}🚀 Invoking Lambda function...${NC}"
echo ""

# Invoke the function
if [ "$VERBOSE" = true ]; then
    sam local invoke "$FUNCTION_NAME" -e "$EVENT_FILE" --template "$TEMPLATE_PATH" --log-file /tmp/sam-logs.log
    echo ""
    echo -e "${YELLOW}📋 Function Logs:${NC}"
    cat /tmp/sam-logs.log
else
    sam local invoke "$FUNCTION_NAME" -e "$EVENT_FILE" --template "$TEMPLATE_PATH"
fi

echo ""
echo -e "${GREEN}✅ Lambda function invocation completed!${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  - Make sure your Phoenix app is running on port 4000"
echo -e "  - Use --verbose flag to see detailed logs"
echo -e "  - Check the Phoenix app logs to see if webhook was received"