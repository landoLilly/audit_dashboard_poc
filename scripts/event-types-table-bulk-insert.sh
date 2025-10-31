#!/bin/bash
# seed-eventtypes-complete.sh

echo "🌱 Seeding EventTypes table with all categories..."

# Set AWS endpoint for local DynamoDB
ENDPOINT="http://localhost:8001"
export AWS_PAGER=""

CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ============================================
# AUTHENTICATION CATEGORY
# ============================================
echo "Adding Authentication Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "1"},
    "EventTypeName": {"S": "UserLogin"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User successfully logged into the system"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "2"},
    "EventTypeName": {"S": "UserLogout"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User logged out of the system"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "3"},
    "EventTypeName": {"S": "LoginFailed"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "Failed login attempt"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "4"},
    "EventTypeName": {"S": "PasswordReset"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User requested or completed password reset"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "5"},
    "EventTypeName": {"S": "PasswordChanged"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User changed their password"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "6"},
    "EventTypeName": {"S": "TokenRefreshed"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "Authentication token was refreshed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "7"},
    "EventTypeName": {"S": "MFAEnabled"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "Multi-factor authentication was enabled"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "8"},
    "EventTypeName": {"S": "MFADisabled"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "Multi-factor authentication was disabled"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "9"},
    "EventTypeName": {"S": "MFAVerified"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User completed MFA verification"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "10"},
    "EventTypeName": {"S": "SessionExpired"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User session timed out"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "11"},
    "EventTypeName": {"S": "AccountLocked"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User account was locked due to failed attempts"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "12"},
    "EventTypeName": {"S": "AccountUnlocked"},
    "Category": {"S": "Authentication"},
    "Description": {"S": "User account was unlocked"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# AUTHORIZATION CATEGORY
# ============================================
echo "Adding Authorization Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "20"},
    "EventTypeName": {"S": "PermissionGranted"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "User was granted new permissions"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "21"},
    "EventTypeName": {"S": "PermissionRevoked"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "User permissions were revoked"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "22"},
    "EventTypeName": {"S": "RoleAssigned"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "User was assigned to a role"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "23"},
    "EventTypeName": {"S": "RoleRemoved"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "User was removed from a role"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "24"},
    "EventTypeName": {"S": "AccessDenied"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "User attempted to access unauthorized resource"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "25"},
    "EventTypeName": {"S": "ElevatedAccessGranted"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "Temporary elevated access was granted"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "26"},
    "EventTypeName": {"S": "ElevatedAccessExpired"},
    "Category": {"S": "Authorization"},
    "Description": {"S": "Temporary elevated access expired"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# DATA ACCESS CATEGORY
# ============================================
echo "Adding DataAccess Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "30"},
    "EventTypeName": {"S": "RecordViewed"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User viewed a specific record"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "31"},
    "EventTypeName": {"S": "RecordCreated"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "New record was created"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "32"},
    "EventTypeName": {"S": "RecordUpdated"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "Existing record was modified"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "33"},
    "EventTypeName": {"S": "RecordDeleted"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "Record was deleted"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "34"},
    "EventTypeName": {"S": "BulkExport"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User exported bulk data"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "35"},
    "EventTypeName": {"S": "FileDownloaded"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User downloaded a file"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "36"},
    "EventTypeName": {"S": "FileUploaded"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User uploaded a file"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "37"},
    "EventTypeName": {"S": "FileDeleted"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User deleted a file"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "38"},
    "EventTypeName": {"S": "SearchPerformed"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "User performed a search query"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "39"},
    "EventTypeName": {"S": "ReportGenerated"},
    "Category": {"S": "DataAccess"},
    "Description": {"S": "Report was generated"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# COMPLIANCE CATEGORY
# ============================================
echo "Adding Compliance Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "40"},
    "EventTypeName": {"S": "ConsentGranted"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User granted consent for data processing"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "41"},
    "EventTypeName": {"S": "ConsentRevoked"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User revoked previously granted consent"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "42"},
    "EventTypeName": {"S": "ConsentUpdated"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User updated consent preferences"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "43"},
    "EventTypeName": {"S": "DataExportRequested"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User requested data export (GDPR)"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "44"},
    "EventTypeName": {"S": "DataAnonymized"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "Personal data was anonymized"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "45"},
    "EventTypeName": {"S": "RightToAccessExercised"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User exercised right to access their data"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "46"},
    "EventTypeName": {"S": "RightToErasureExercised"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User requested data deletion (GDPR)"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "47"},
    "EventTypeName": {"S": "DataPortabilityRequested"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User requested data export"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "48"},
    "EventTypeName": {"S": "PrivacyPolicyAccepted"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User accepted privacy policy"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "49"},
    "EventTypeName": {"S": "TermsOfServiceAccepted"},
    "Category": {"S": "Compliance"},
    "Description": {"S": "User accepted terms of service"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# PROFILE CATEGORY
# ============================================
echo "Adding Profile Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "50"},
    "EventTypeName": {"S": "ProfileCreated"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User profile was created"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "51"},
    "EventTypeName": {"S": "ProfileUpdated"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User profile was modified"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "52"},
    "EventTypeName": {"S": "ProfileDeleted"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User profile was deleted"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "53"},
    "EventTypeName": {"S": "EmailChanged"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User changed their email address"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "54"},
    "EventTypeName": {"S": "PhoneChanged"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User changed their phone number"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "55"},
    "EventTypeName": {"S": "AddressUpdated"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User updated their address"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "56"},
    "EventTypeName": {"S": "PreferencesUpdated"},
    "Category": {"S": "Profile"},
    "Description": {"S": "User updated their preferences"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# API CATEGORY
# ============================================
echo "Adding API Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "60"},
    "EventTypeName": {"S": "APIKeyGenerated"},
    "Category": {"S": "API"},
    "Description": {"S": "New API key was generated"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "61"},
    "EventTypeName": {"S": "APIKeyRevoked"},
    "Category": {"S": "API"},
    "Description": {"S": "API key was revoked"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "62"},
    "EventTypeName": {"S": "APICallSucceeded"},
    "Category": {"S": "API"},
    "Description": {"S": "Successful API call"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "63"},
    "EventTypeName": {"S": "APICallFailed"},
    "Category": {"S": "API"},
    "Description": {"S": "Failed API call"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "64"},
    "EventTypeName": {"S": "APIRateLimitExceeded"},
    "Category": {"S": "API"},
    "Description": {"S": "API rate limit was exceeded"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "65"},
    "EventTypeName": {"S": "WebhookReceived"},
    "Category": {"S": "API"},
    "Description": {"S": "Webhook event was received"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "66"},
    "EventTypeName": {"S": "WebhookProcessed"},
    "Category": {"S": "API"},
    "Description": {"S": "Webhook event was successfully processed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "67"},
    "EventTypeName": {"S": "WebhookFailed"},
    "Category": {"S": "API"},
    "Description": {"S": "Webhook processing failed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# SYSTEM CATEGORY
# ============================================
echo "Adding System Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "70"},
    "EventTypeName": {"S": "ConfigurationChanged"},
    "Category": {"S": "System"},
    "Description": {"S": "System configuration was modified"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "71"},
    "EventTypeName": {"S": "ServiceStarted"},
    "Category": {"S": "System"},
    "Description": {"S": "Service or application started"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "72"},
    "EventTypeName": {"S": "ServiceStopped"},
    "Category": {"S": "System"},
    "Description": {"S": "Service or application stopped"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "73"},
    "EventTypeName": {"S": "BackupCompleted"},
    "Category": {"S": "System"},
    "Description": {"S": "Data backup completed successfully"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "74"},
    "EventTypeName": {"S": "BackupFailed"},
    "Category": {"S": "System"},
    "Description": {"S": "Data backup failed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "75"},
    "EventTypeName": {"S": "MaintenanceStarted"},
    "Category": {"S": "System"},
    "Description": {"S": "System maintenance began"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "76"},
    "EventTypeName": {"S": "MaintenanceCompleted"},
    "Category": {"S": "System"},
    "Description": {"S": "System maintenance completed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "77"},
    "EventTypeName": {"S": "ErrorOccurred"},
    "Category": {"S": "System"},
    "Description": {"S": "System error occurred"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# SECURITY CATEGORY
# ============================================
echo "Adding Security Category events..."

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "80"},
    "EventTypeName": {"S": "SuspiciousActivityDetected"},
    "Category": {"S": "Security"},
    "Description": {"S": "Potential security threat detected"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "81"},
    "EventTypeName": {"S": "IPAddressBlocked"},
    "Category": {"S": "Security"},
    "Description": {"S": "IP address was blocked"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "82"},
    "EventTypeName": {"S": "SecurityAlertTriggered"},
    "Category": {"S": "Security"},
    "Description": {"S": "Security monitoring alert was triggered"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "83"},
    "EventTypeName": {"S": "EncryptionKeyRotated"},
    "Category": {"S": "Security"},
    "Description": {"S": "Encryption key was rotated"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "84"},
    "EventTypeName": {"S": "CertificateExpiring"},
    "Category": {"S": "Security"},
    "Description": {"S": "Security certificate is nearing expiration"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

# ============================================
# INTEGRATION CATEGORY
# ============================================

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "90"},
    "EventTypeName": {"S": "ThirdPartyConnected"},
    "Category": {"S": "Integration"},
    "Description": {"S": "Third-party service was connected"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "91"},
    "EventTypeName": {"S": "ThirdPartyDisconnected"},
    "Category": {"S": "Integration"},
    "Description": {"S": "Third-party service was disconnected"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "92"},
    "EventTypeName": {"S": "DataSyncCompleted"},
    "Category": {"S": "Integration"},
    "Description": {"S": "Data synchronization completed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "93"},
    "EventTypeName": {"S": "DataSyncFailed"},
    "Category": {"S": "Integration"},
    "Description": {"S": "Data synchronization failed"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

aws dynamodb put-item \
    --endpoint-url $ENDPOINT \
    --table-name EventTypes --item '{
    "EventTypeId": {"N": "94"},
    "EventTypeName": {"S": "ExternalAPICallMade"},
    "Category": {"S": "Integration"},
    "Description": {"S": "Call made to external API"},
    "IsActive": {"BOOL": true},
    "CreatedAt": {"S": "'$CURRENT_TIMESTAMP'"}
}'

echo "✅ Integration Category events seeded successfully!"
echo "📊 Total Integration events added: 5"