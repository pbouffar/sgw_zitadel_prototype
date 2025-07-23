#!/bin/bash

#
# This script creates a JWT with the proper header and payload and signs it with the RS256 algorithm.
# It is used to authenticate a Service User with a private JWT.
#
# THIS IS A PYTHON SCRIPT FROM ZITADEL CONVERTED TO BASH BY CIRCUIT.
# The python can be found here: 
#   https://zitadel.com/docs/guides/integrate/service-users/private-key-jwt#3-create-a-jwt-and-sign-with-private-key
#

# --- Usage Function ---
usage() {
  echo "Usage: $0 <service_user_id> <private_key_path> <key_id> <api_url>"
  echo ""
  echo "Arguments:"
  echo "  <service_user_id>  : Your ZITADEL service user ID."
  echo "  <private_key>      : The key should be in PKCS#8 format (BEGIN PRIVATE KEY)."
  echo "  <key_id>           : The key ID associated with your private key."
  echo "  <api_url>          : The base URL of your ZITADEL API (e.g., https://your-instance.zitadel.cloud)."
  echo ""
  echo "Example:"
  echo "  $0 '289379876543210987' './my_private_key.pem' '329278769615382362' 'https://my-zitadel-instance.zitadel.cloud'"
  exit 1
}

# --- Parse Command Line Arguments ---
if [ "$#" -ne 4 ]; then
  usage
fi

service_user_id="$1"
private_key="$2"
key_id="$3"
api_url="$4"

# --- Helper function for Base64Url encoding ---
# This function handles standard base64 output and converts it to URL-safe format
# by removing padding (=) and replacing + with - and / with _
base64url_encode() {
  echo -n "$1" | base64 | tr -d '\n=' | tr '+/' '-_'
}

# --- Generate Timestamps (Unix epoch time in seconds) ---
# iat (issued at): current UTC time
iat=$(date +%s)
#iat="$(date -u +'%Y-%m-%d %H:%M:%S.%6N%:::z')"

# exp (expiration time): 5 minutes from now (300 seconds)
exp=$(($(date +%s) + 300))
#exp="$(date -u --date='+5 minutes' +'%Y-%m-%d %H:%M:%S.%6N%:::z')"

echo "iat $iat"
echo "exp $exp"

# --- Construct JWT Header JSON ---
# Using jq to create the JSON string for the header
header_json=$(jq -n \
  --arg alg "RS256" \
  --arg kid "$key_id" \
  '{alg: $alg, kid: $kid}')

# --- Construct JWT Payload (Claims) JSON ---
# Using jq to create the JSON string for the payload
payload_json=$(jq -n \
  --arg iss "$service_user_id" \
  --arg sub "$service_user_id" \
  --arg aud "$api_url" \
  --arg exp "$exp" \
  --arg iat "$iat" \
  '{iss: $iss, sub: $sub, aud: $aud, exp: $exp, iat: $iat}')

# --- Base64Url Encode Header and Payload ---
encoded_header=$(base64url_encode "$header_json")
encoded_payload=$(base64url_encode "$payload_json")

# --- Data to be Signed ---
# This is the concatenation of the encoded header and payload, separated by a dot.
data_to_sign="${encoded_header}.${encoded_payload}"

# --- Create a temporary file for the private key ---
# openssl dgst requires a file path for the private key.
# In a real-world scenario, consider more secure ways to handle the private key,
# e.g., reading from a secure vault or environment variable.
private_key_file=$(mktemp)
echo "$private_key" > "$private_key_file"

# --- Sign the data ---
# 1. 'echo -n "$data_to_sign"': Outputs the data to be signed without a trailing newline.
# 2. 'openssl dgst -sha256 -sign "$private_key_file"': Computes the SHA256 hash and signs it
#    using the provided private key. The output is a raw binary signature.
# 3. '| base64url_encode': Pipes the binary signature to our helper function for Base64Url encoding.
signature=$(echo -n "$data_to_sign" | openssl dgst -sha256 -sign "$private_key_file" | base64url_encode)

# --- Clean up the temporary private key file ---
rm "$private_key_file"

# --- Assemble the final JWT ---
encoded_jwt="${data_to_sign}.${signature}"

# Generated JWT
echo "${encoded_jwt}"