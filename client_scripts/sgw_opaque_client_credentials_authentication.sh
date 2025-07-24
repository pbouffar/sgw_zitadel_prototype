#!/bin/bash

SGW_ZITADEL_DEMO_SERVER="http://localhost:8090"
ZITADEL_SERVER="http://localhost:8080"

CLIENT_ID="sgw_pierre"
CLIENT_SECRET="5OQ8eh6PQLjzcJKhMSSPVC7JXAbpcveGMm0A4qsQAiVDUHxHanrSE3ri4UZ2Z4gw"
PROJECT_ID="330021820281431898" # SGW_Project_Cisco. The Zitadel project's Resource ID.

RESPONSE=$(curl -sS --request POST \
  --url "${ZITADEL_SERVER}/oauth/v2/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "grant_type=client_credentials" \
  --data "scope=openid profile urn:zitadel:iam:org:project:id:${PROJECT_ID}:aud" \
  --user "${CLIENT_ID}:${CLIENT_SECRET}")

#echo $RESPONSE | jq

# Extract the access_token using jq
# -r flag ensures raw output (without quotes)
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

echo ""; echo "Accessing a secured endpoint...."

RESPONSE=$(curl -sS -X GET "${SGW_ZITADEL_DEMO_SERVER}/secured" \
     -H "Authorization: Bearer $ACCESS_TOKEN")

echo $RESPONSE

echo ""; echo "Accessing a public endpoint...."

RESPONSE=$(curl -sS -X GET "${SGW_ZITADEL_DEMO_SERVER}/public/hello")

echo $RESPONSE