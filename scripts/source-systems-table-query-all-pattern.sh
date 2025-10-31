#!/bin/bash
# query-sourcesystems.sh
# Query scripts for SourceSystems table using GSIs

ENDPOINT="http://localhost:8001"
export AWS_PAGER=""

echo "================================================"
echo "SourceSystems Table Query Scripts"
echo "================================================"

# Function to pretty print JSON
print_result() {
    echo -e "\n$1"
    echo "----------------------------------------"
}

# ============================================
# 1. Query by Primary Key (SystemId)
# ============================================
query_by_id() {
    local system_id=$1
    print_result "1. Get SourceSystem by ID (SystemId = $system_id)"
    aws dynamodb get-item \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --key '{"SystemId": {"N": "'$system_id'"}}' \
        --output json | jq '.Item'
}

# ============================================
# 2. Query using GSI1-SystemName
# ============================================
query_by_system_name() {
    local system_name=$1
    print_result "2. Query by SystemName using GSI1: '$system_name'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --index-name GSI1-SystemName \
        --key-condition-expression "SystemName = :name" \
        --expression-attribute-values '{":name":{"S":"'$system_name'"}}' \
        --output json | jq '.Items'
}

# ============================================
# 3. Query using GSI2-SystemType
# ============================================
query_by_system_type() {
    local system_type=$1
    print_result "3. Query by SystemType using GSI2: '$system_type'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --index-name GSI2-SystemType \
        --key-condition-expression "SystemType = :type" \
        --expression-attribute-values '{":type":{"S":"'$system_type'"}}' \
        --output json | jq '.Items'
}

# ============================================
# 4. Query Active Systems by Type
# ============================================
query_active_by_type() {
    local system_type=$1
    print_result "4. Query Active Systems of Type: '$system_type'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --index-name GSI2-SystemType \
        --key-condition-expression "SystemType = :type" \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":type":{"S":"'$system_type'"}, ":active":{"BOOL":true}}' \
        --output json | jq '.Items'
}

# ============================================
# 5. Get Count of Systems by Type
# ============================================
count_by_type() {
    local system_type=$1
    print_result "5. Count Systems of Type: '$system_type'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --index-name GSI2-SystemType \
        --key-condition-expression "SystemType = :type" \
        --expression-attribute-values '{":type":{"S":"'$system_type'"}}' \
        --select COUNT \
        --output json | jq '.Count'
}

# ============================================
# 6. Scan All System Types (Distinct)
# ============================================
get_all_system_types() {
    print_result "6. Get All Unique System Types"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --projection-expression "SystemType" \
        --output json | jq -r '.Items[].SystemType.S' | sort -u
}

# ============================================
# 7. Get All System Names
# ============================================
get_all_system_names() {
    print_result "7. Get All System Names"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --projection-expression "SystemName, SystemType, IsActive" \
        --output json | jq -r '.Items[] | "\(.SystemName.S) (\(.SystemType.S)) - Active: \(.IsActive.BOOL)"'
}

# ============================================
# 8. Query All Active Systems
# ============================================
query_all_active() {
    print_result "8. Get All Active Systems"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":active":{"BOOL":true}}' \
        --output json | jq -r '.Items[] | "\(.SystemId.N): \(.SystemName.S) (\(.SystemType.S))"'
}

# ============================================
# 9. Query All Inactive Systems
# ============================================
query_all_inactive() {
    print_result "9. Get All Inactive Systems"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":active":{"BOOL":false}}' \
        --output json | jq -r '.Items[] | "\(.SystemId.N): \(.SystemName.S) (\(.SystemType.S))"'
}

# ============================================
# 10. Get Summary Statistics
# ============================================
get_summary_stats() {
    print_result "10. SourceSystems Summary Statistics"
    
    echo "Total SourceSystems:"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --select COUNT \
        --output json | jq '.Count'
    
    echo -e "\nSystems by Type:"
    for type in "Application" "Service" "Integration" "Webhook"; do
        count=$(aws dynamodb query \
            --endpoint-url $ENDPOINT \
            --table-name SourceSystems \
            --index-name GSI2-SystemType \
            --key-condition-expression "SystemType = :type" \
            --expression-attribute-values '{":type":{"S":"'$type'"}}' \
            --select COUNT \
            --output json 2>/dev/null | jq '.Count // 0')
        printf "%-20s: %d\n" "$type" "$count"
    done
    
    echo -e "\nActive Systems:"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":active":{"BOOL":true}}' \
        --select COUNT \
        --output json | jq '.Count'
    
    echo -e "\nInactive Systems:"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":active":{"BOOL":false}}' \
        --select COUNT \
        --output json | jq '.Count'
}

# ============================================
# 11. Search Systems by Description
# ============================================
search_by_description() {
    local search_term=$1
    print_result "11. Search Systems by Description containing: '$search_term'"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --filter-expression "contains(Description, :term)" \
        --expression-attribute-values '{":term":{"S":"'$search_term'"}}' \
        --projection-expression "SystemName, SystemType, Description" \
        --output json | jq -r '.Items[] | "\(.SystemName.S) (\(.SystemType.S)): \(.Description.S)"'
}

# ============================================
# 12. Get System Details by Name
# ============================================
get_system_details() {
    local system_name=$1
    print_result "12. Get Complete Details for System: '$system_name'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name SourceSystems \
        --index-name GSI1-SystemName \
        --key-condition-expression "SystemName = :name" \
        --expression-attribute-values '{":name":{"S":"'$system_name'"}}' \
        --output json | jq '.Items[0]'
}

# ============================================
# 13. List Systems by Multiple Types
# ============================================
query_multiple_types() {
    print_result "13. Query Multiple System Types"
    for type in "Application" "Service" "Integration"; do
        echo -e "\n--- $type ---"
        aws dynamodb query \
            --endpoint-url $ENDPOINT \
            --table-name SourceSystems \
            --index-name GSI2-SystemType \
            --key-condition-expression "SystemType = :type" \
            --expression-attribute-values '{":type":{"S":"'$type'"}}' \
            --projection-expression "SystemId, SystemName, Description, IsActive" \
            --output json | jq -r '.Items[] | "\(.SystemId.N): \(.SystemName.S) (Active: \(.IsActive.BOOL))"'
    done
}

# ============================================
# 14. Batch Get Multiple Systems by ID
# ============================================
batch_get_systems() {
    print_result "14. Batch Get Systems by IDs (1, 2, 3)"
    aws dynamodb batch-get-item \
        --endpoint-url $ENDPOINT \
        --request-items '{
            "SourceSystems": {
                "Keys": [
                    {"SystemId": {"N": "1"}},
                    {"SystemId": {"N": "2"}},
                    {"SystemId": {"N": "3"}}
                ]
            }
        }' \
        --output json | jq '.Responses.SourceSystems'
}

# ============================================
# Main Menu
# ============================================
show_menu() {
    echo -e "\n================================================"
    echo "SourceSystems Query Menu"
    echo "================================================"
    echo "1.  Query by SystemId"
    echo "2.  Query by SystemName (GSI1)"
    echo "3.  Query by SystemType (GSI2)"
    echo "4.  Query Active Systems by Type"
    echo "5.  Count Systems by Type"
    echo "6.  Get All System Types"
    echo "7.  Get All System Names"
    echo "8.  Get All Active Systems"
    echo "9.  Get All Inactive Systems"
    echo "10. Get Summary Statistics"
    echo "11. Search by Description"
    echo "12. Get System Details by Name"
    echo "13. Query Multiple Types"
    echo "14. Batch Get Systems"
    echo "15. Run All Queries"
    echo "0.  Exit"
    echo "================================================"
}

# Main execution
if [ $# -eq 0 ]; then
    show_menu
    read -p "Enter choice: " choice
    
    case $choice in
        1) 
            read -p "Enter SystemId: " id
            query_by_id "$id"
            ;;
        2) 
            read -p "Enter SystemName: " name
            query_by_system_name "$name"
            ;;
        3) 
            read -p "Enter SystemType: " type
            query_by_system_type "$type"
            ;;
        4) 
            read -p "Enter SystemType: " type
            query_active_by_type "$type"
            ;;
        5) 
            read -p "Enter SystemType: " type
            count_by_type "$type"
            ;;
        6) get_all_system_types ;;
        7) get_all_system_names ;;
        8) query_all_active ;;
        9) query_all_inactive ;;
        10) get_summary_stats ;;
        11) 
            read -p "Enter search term: " term
            search_by_description "$term"
            ;;
        12) 
            read -p "Enter SystemName: " name
            get_system_details "$name"
            ;;
        13) query_multiple_types ;;
        14) batch_get_systems ;;
        15)
            query_by_id "1"
            query_by_system_name "WebPortal"
            query_by_system_type "Application"
            query_active_by_type "Service"
            get_summary_stats
            query_multiple_types
            ;;
        0) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
else
    # Command line arguments
    case $1 in
        --by-id) query_by_id "$2" ;;
        --by-name) query_by_system_name "$2" ;;
        --by-type) query_by_system_type "$2" ;;
        --active-type) query_active_by_type "$2" ;;
        --count) count_by_type "$2" ;;
        --types) get_all_system_types ;;
        --names) get_all_system_names ;;
        --active) query_all_active ;;
        --inactive) query_all_inactive ;;
        --stats) get_summary_stats ;;
        --search) search_by_description "$2" ;;
        --details) get_system_details "$2" ;;
        --multiple) query_multiple_types ;;
        --batch) batch_get_systems ;;
        --all) 
            query_by_id "1"
            query_by_system_name "WebPortal"
            query_by_system_type "Application"
            get_summary_stats
            ;;
        *) 
            echo "Usage: $0 [--by-id ID|--by-name NAME|--by-type TYPE|--stats|--all]"
            exit 1
            ;;
    esac
fi