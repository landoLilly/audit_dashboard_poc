#!/bin/bash
# query-eventtypes.sh
# Query scripts for EventTypes table using GSIs

ENDPOINT="http://localhost:8001"
export AWS_PAGER=""

echo "================================================"
echo "EventTypes Table Query Scripts"
echo "================================================"

# Function to pretty print JSON
print_result() {
    echo -e "\n$1"
    echo "----------------------------------------"
}

# ============================================
# 1. Query by Primary Key (EventTypeId)
# ============================================
query_by_id() {
    print_result "1. Get EventType by ID (EventTypeId = 1)"
    aws dynamodb get-item \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --key '{"EventTypeId": {"N": "1"}}' \
        --output json | jq '.Item'
}

# ============================================
# 2. Query using GSI1-EventTypeName
# ============================================
query_by_event_type_name() {
    local event_name=$1
    print_result "2. Query by EventTypeName using GSI1: '$event_name'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --index-name GSI1-EventTypeName \
        --key-condition-expression "EventTypeName = :name" \
        --expression-attribute-values '{":name":{"S":"'$event_name'"}}' \
        --output json | jq '.Items'
}

# ============================================
# 3. Query using GSI2-Category
# ============================================
query_by_category() {
    local category=$1
    print_result "3. Query by Category using GSI2: '$category'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --index-name GSI2-Category \
        --key-condition-expression "Category = :cat" \
        --expression-attribute-values '{":cat":{"S":"'$category'"}}' \
        --output json | jq '.Items'
}

# ============================================
# 4. Query Active Events by Category
# ============================================
query_active_by_category() {
    local category=$1
    print_result "4. Query Active Events in Category: '$category'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --index-name GSI2-Category \
        --key-condition-expression "Category = :cat" \
        --filter-expression "IsActive = :active" \
        --expression-attribute-values '{":cat":{"S":"'$category'"}, ":active":{"BOOL":true}}' \
        --output json | jq '.Items'
}

# ============================================
# 5. Get Count of Events by Category
# ============================================
count_by_category() {
    local category=$1
    print_result "5. Count Events in Category: '$category'"
    aws dynamodb query \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --index-name GSI2-Category \
        --key-condition-expression "Category = :cat" \
        --expression-attribute-values '{":cat":{"S":"'$category'"}}' \
        --select COUNT \
        --output json | jq '.Count'
}

# ============================================
# 6. Scan All Categories (Distinct)
# ============================================
get_all_categories() {
    print_result "6. Get All Unique Categories"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --projection-expression "Category" \
        --output json | jq -r '.Items[].Category.S' | sort -u
}

# ============================================
# 7. Get All Event Type Names
# ============================================
get_all_event_names() {
    print_result "7. Get All Event Type Names"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --projection-expression "EventTypeName, Category" \
        --output json | jq -r '.Items[] | "\(.EventTypeName.S) (\(.Category.S))"'
}

# ============================================
# 8. Query Multiple Categories (using batch)
# ============================================
query_multiple_categories() {
    print_result "8. Query Multiple Categories (Authentication, Authorization, Security)"
    for category in "Authentication" "Authorization" "Security"; do
        echo -e "\n--- $category ---"
        aws dynamodb query \
            --endpoint-url $ENDPOINT \
            --table-name EventTypes \
            --index-name GSI2-Category \
            --key-condition-expression "Category = :cat" \
            --expression-attribute-values '{":cat":{"S":"'$category'"}}' \
            --projection-expression "EventTypeId, EventTypeName, Description" \
            --output json | jq -r '.Items[] | "\(.EventTypeId.N): \(.EventTypeName.S)"'
    done
}

# ============================================
# 9. Get Summary Statistics
# ============================================
get_summary_stats() {
    print_result "9. EventTypes Summary Statistics"
    
    echo "Total EventTypes:"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --select COUNT \
        --output json | jq '.Count'
    
    echo -e "\nEvents by Category:"
    for category in "Authentication" "Authorization" "DataAccess" "Compliance" "Profile" "API" "System" "Security" "Integration"; do
        count=$(aws dynamodb query \
            --endpoint-url $ENDPOINT \
            --table-name EventTypes \
            --index-name GSI2-Category \
            --key-condition-expression "Category = :cat" \
            --expression-attribute-values '{":cat":{"S":"'$category'"}}' \
            --select COUNT \
            --output json | jq '.Count')
        printf "%-20s: %d\n" "$category" "$count"
    done
}

# ============================================
# 10. Search EventTypes by Description (contains)
# ============================================
search_by_description() {
    local search_term=$1
    print_result "10. Search EventTypes by Description containing: '$search_term'"
    aws dynamodb scan \
        --endpoint-url $ENDPOINT \
        --table-name EventTypes \
        --filter-expression "contains(Description, :term)" \
        --expression-attribute-values '{":term":{"S":"'$search_term'"}}' \
        --projection-expression "EventTypeName, Category, Description" \
        --output json | jq -r '.Items[] | "\(.EventTypeName.S) (\(.Category.S)): \(.Description.S)"'
}

# ============================================
# Main Menu
# ============================================
show_menu() {
    echo -e "\n================================================"
    echo "EventTypes Query Menu"
    echo "================================================"
    echo "1. Query by EventTypeId"
    echo "2. Query by EventTypeName (GSI1)"
    echo "3. Query by Category (GSI2)"
    echo "4. Query Active Events by Category"
    echo "5. Count Events by Category"
    echo "6. Get All Categories"
    echo "7. Get All Event Names"
    echo "8. Query Multiple Categories"
    echo "9. Get Summary Statistics"
    echo "10. Search by Description"
    echo "11. Run All Queries"
    echo "0. Exit"
    echo "================================================"
}

# Main execution
if [ $# -eq 0 ]; then
    show_menu
    read -p "Enter choice: " choice
    
    case $choice in
        1) query_by_id ;;
        2) 
            read -p "Enter EventTypeName: " name
            query_by_event_type_name "$name"
            ;;
        3) 
            read -p "Enter Category: " cat
            query_by_category "$cat"
            ;;
        4) 
            read -p "Enter Category: " cat
            query_active_by_category "$cat"
            ;;
        5) 
            read -p "Enter Category: " cat
            count_by_category "$cat"
            ;;
        6) get_all_categories ;;
        7) get_all_event_names ;;
        8) query_multiple_categories ;;
        9) get_summary_stats ;;
        10) 
            read -p "Enter search term: " term
            search_by_description "$term"
            ;;
        11)
            query_by_id
            query_by_event_type_name "UserLogin"
            query_by_category "Authentication"
            query_active_by_category "Authorization"
            count_by_category "DataAccess"
            get_all_categories
            get_all_event_names
            query_multiple_categories
            get_summary_stats
            search_by_description "user"
            ;;
        0) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
else
    # Command line arguments
    case $1 in
        --by-id) query_by_id ;;
        --by-name) query_by_event_type_name "$2" ;;
        --by-category) query_by_category "$2" ;;
        --active-category) query_active_by_category "$2" ;;
        --count) count_by_category "$2" ;;
        --categories) get_all_categories ;;
        --names) get_all_event_names ;;
        --multiple) query_multiple_categories ;;
        --stats) get_summary_stats ;;
        --search) search_by_description "$2" ;;
        --all) 
            query_by_id
            query_by_event_type_name "UserLogin"
            query_by_category "Authentication"
            get_summary_stats
            ;;
        *) 
            echo "Usage: $0 [--by-id|--by-name NAME|--by-category CAT|--stats|--all]"
            exit 1
            ;;
    esac
fi