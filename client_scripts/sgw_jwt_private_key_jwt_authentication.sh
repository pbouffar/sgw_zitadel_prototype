#!/bin/bash

SGW_ZITADEL_DEMO_SERVER="http://localhost:8090"
ZITADEL_SERVER="http://localhost:8080"

# --- Configuration (Replace with your actual values) ---
service_user_id="329282488167868250" # sgw_client_app

# IMPORTANT: Ensure your private key is correctly formatted with actual newlines.
# For security, consider reading this from a file or environment variable in production.
private_key="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEApL+VDKU+UGpsIj2go33uJ/+U1IOIE2fjS8RLs1Q/EvzL5+Wj
Y3ruansDKNm6nA6oNmsJTJXckDYZLnc1Rc2EOb1eiiyhL166p9aDd4oxZV9BsRfu
lPAgff5rKx8c5xdarTSGbFyQ3lsdXPsfc/DGmj3RdaCnZBWlCDeSAy5AZrFZZxFZ
Zl6UGzThLEVOEiaK3k+LX0+jzWR3yjdsoFdCq8dI/gG3/NLlQU/wXF83WB5CPRHg
MqC1V+xYdTdfNALbe8IzvlAeVu+ULWExyg3ZYoC6JRSIV2PTIy0Lopi9J36VYCk/
a1+0JGTvuvRGf0DzDn7pwth8KEkbHdFAoWV6LQIDAQABAoIBAANgqlw6gmG2O/SG
pUITDF5Mj/K8iZq1lH0ZyG5rKbD96JVmBgUhJ8ucSa8g4rqWOTq/fnl6pi15KD0e
W4r3F/ZHTlhF3ExWma3V/jN0COfGT5EVEluCVzyjX2U1wrJS2RV0iSqJrbypSzgY
n3kRbXjvD6EBWSDBcRFyx/1I0L5qNE+tMCQOa9eI7c61rgUfbjPYn4iPe5DTBU9B
zhdn5VG+iLsqEzUX6H+N3cUV/NKltK9mekCCsgsUgIL6xMWgYRzduSUi4K1K9ngb
UBEZKBPoRNLkzK1NQ8WgoLm72eVrkvBy4UR1w2eAYRBQU3eaQ7UV+2GCCTUPWTEV
sYplRXECgYEAz4cD8QqmVZex+gSsU+rJK/JtDKjoVkaoDRmqCPYeDd0BbVX8ulMg
/W09aQ8DpTOH/wR0MZJkCvFqVWO1NViF0rJ3IMkDvqF8Rd97yPYUWmMJYVcKnQva
bEiOl0Wam2kUQ6PBv3zKV6wd0imr8yq+wdBiqjJz4Rhe9WmtxZhacDUCgYEAyzqe
T0yXpqW+qiBhh/fF6RaugLskf2Beq8b7PQKqCDJaeiayPXK8g/na6pP+6ns90xAL
SxYPEMItMo55sJqrGOnc7ypC/9QWuKOn1bZjnBLS4onhDs9SSCVjzIVcMqDTO8ns
k5DmUg59TyoGY/ZXiflbIUV/joAl7RjK8cBJERkCgYAWvtaYwbEPaovwOjjlDbO0
5GI9Y/nrEt1yaiCv0MHkhReV8zm69keEX0e+zw14OtiqA8P0dvYOGP2tlDsVOLma
KUNTTZTifPKQ+fioQwhiC77Ic3DPW7A59A3k2JUkeXTmIPmoUjYfO9cc5MJa6ZF0
zrExtEvtHO2zejy4joVDDQKBgQCD6aGWYWXSIqVWsjv8UISi3jkYj+CJ2Vi58Sdk
m5UYSu7VeMabAh2BIK3LM5L0Slh/5lseOsw+mXtS5I3yZwKF4k6o4uqoOdchtACd
xIx1YvaFWu+9eC61a6eSukF1D1Ts6w1nX1dQjd0ihGmvetepVDSlrQG10lJLypr4
PlJvCQKBgCl9chLCeuw9fF3yQITNNVnDM0yXaz5n0MPCuaciCLHI2G1fENzz/S3f
5Re6i4aO4EnltCv0HSjxsFubvEkVBN8T+OQQE7SdMHpZgOD46NgZAkI2Uhip+dPK
DId1QwLyIkXZGEC9IZIEHWsfb+4QKI3HRH517sTrELM6Z3Xzmnij
-----END RSA PRIVATE KEY-----"
key_id="329282866460534618"

# ZITADEL API URL (replace if needed)
api_url="http://localhost:8080"

echo "Generating encoded JWT..."

ENCODED_JWT=$(python3 ./generate_jwt.py "${service_user_id}" "${private_key}" "${key_id}" "${api_url}")

#echo "Encoded JWT: $ENCODED_JWT"

RESPONSE=$(curl -sS --request POST \
  --url ${ZITADEL_SERVER}/oauth/v2/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
  --data scope='openid' \
  --data assertion=$ENCODED_JWT)

#echo $RESPONSE | jq

# Extract the access_token using jq
# -r flag ensures raw output (without quotes)
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

echo ""; echo "Accessing a secured endpoint...."

curl -sS -X GET "${SGW_ZITADEL_DEMO_SERVER}/secured" \
     -H "Authorization: Bearer $ACCESS_TOKEN"

echo ""; echo "Accessing a public endpoint...."

curl -sS -X GET "${SGW_ZITADEL_DEMO_SERVER}/public/hello"

