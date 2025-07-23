#!/bin/bash

SGW_ZITADEL_DEMO_SERVER="http://localhost:8090"
ZITADEL_SERVER="http://localhost:8080"

CLIENT_ID="sgw_client_app"
CLIENT_SECRET="bhwbF4APgAclItV1Idi8YxyKDTYJKO0WHDulXsEWqlnvajDpHMyYe3sGoQ1S84hP"

RESPONSE=$(curl -sS --request POST \
  --url ${ZITADEL_SERVER}/oauth/v2/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=client_credentials \
  --data scope='openid profile' \
  --user "$CLIENT_ID:$CLIENT_SECRET")

#echo $RESPONSE | jq

# Extract the access_token using jq
# -r flag ensures raw output (without quotes)
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

echo ""; echo "Accessing a SO Mock API endpoint...."

RESPONSE=$(curl -sS -X GET "${SGW_ZITADEL_DEMO_SERVER}/call-downstream" \
     -H "Authorization: Bearer $ACCESS_TOKEN")

echo $RESPONSE

