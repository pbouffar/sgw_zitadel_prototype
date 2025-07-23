#!/bin/bash

SGW_ZITADEL_DEMO_SERVER="http://localhost:8090"
ZITADEL_SERVER="http://localhost:8080"

# --- Configuration (Replace with your actual values) ---
service_user_id="330022031053596506" # sgw_pierre

# IMPORTANT: Ensure your private key is correctly formatted with actual newlines.
# For security, consider reading this from a file or environment variable in production.
private_key="-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAsvhDk9YpgPTzDpv7NdDL4M6+hqBagA7x8oHFz8CqfHb9vrn8
kS1nOmH+8SoPQMf8ATugMU7TjkZP0Dgt8ICfhZYdsYd8j+MRUytRwqz6ZGdy+OAS
OEghaoeZC9uNHxQkCgRNrdJuqZmZgmxTKMzfomZ74qmLsV+bdgZh7PkJnIm5oCXV
9dV2qloMwIoGEV/c0QbbixQ/p+Nznlldj/bmVxdLVoOBZF6rFxuh8uyyVKNRR7fD
Gq+adAHECh8VY7LcuXGDlqCWNgFrEArbNH6abo+V7Lkr+JxUBgDkQvKWCt/Ohw33
HSaGdRdJ6bFKT01OLNnxStl4roajw3kbW27S5wIDAQABAoIBAAeyYqGgg79uiWd2
8NpTJPmBmrMKgWnheqlNyHaTWCGrMmV59TE/LSHXJhI0F1zXXPCmolCMjc+gGX2g
dOVTesjReGxyobpEbzHO+qCvNMONqWWnqVDvVTSSKVRXuF1+TcB6h+ayVp0HpJD1
3Ku0B+ghlTFdzkquDG8KfjqlSTMIrM3VfuE10JgqvU2ZIvf4IPg4RgSYOOn+amp7
oZN8cqgN4kMZzq4EN3/nSf5hZd63bXRp/CGLzQy07YF5I+cOaAlRARheabKE2WyP
KwGe/toQkemvik+spQzcMelVXkNLUYNcsG/IxzQLSCDlzvuCBMhL9vjuFiTJHecp
r0pyliECgYEA6dmwyuLFMQtrF72c6CZqmJxumUDl91hGfLVletVn6htt9AiHbx9V
ybhJvHwyH8Viuw9c/DW5l9E+nKypPTO2IWO3D0mj4qzMQU8PXMtC/AzougcfZN9h
xyVB+FEK0nNvyYQTN7B4GIdKp3s0swQJp24b1rCDzRHEWyPRnpz9++ECgYEAw+vZ
7yvjMYEFQhgYQRqt+L2iAFw73Evb9lQr4EQGdQjifSLVt13LepZKNT2+aPMi9g78
2zEU1n4R1lrnZC6Bg7pFkOxYS7mpEL0oxAzcNLJzaBzfwuakKdQ8DwCMeQGzEYeS
FhPJRTVfn+rhyOcr0/LyTks3vFYduxZnjFq458cCgYADqEz0j2FoJ/aP035dvyQR
qPit2u791Fqd3rRsnGPYrH8mvu9nVIUh94jnssWR66Nkq5PXuftiHXquNqEa/PEP
SqD1U0CF7g/vwY3K9L7idE07g5sBF+FOnQ2QFaxmqDmKXE90ooTuVUdcoTesyRZh
kP5MeExHa8y3ZDMGGQx74QKBgBzCPhdRheP6YF83UjgcRnVAwMr0vwSzTfJ2oIom
8huz1iswNdbYucmgzfvKuGyHZBZiVNOH/NsPXmbsqRKXkQNZEGUZjExxUFPYsGc2
zAwgNbiOpHnjiS1qrfY1ymjoyvRDxjnfZaf3EbZTsBjhdhmCi/baK7BFo8+WllSP
7Jx5AoGABt1h5oodmormv0dIfmSpZf8yGQguvNRZwI49tCeNLhoOctoOs3uuBtXA
bcNGm243L4+GAFSlFolGoShhTLYbOTdXbsaAERe2xpCDGycflv2HkGctloBirEbA
3Gx47kK6hN8LSyIVCETFOH+lln8SXbPFxjLo4L+AI6dKWeSOa6s=
-----END RSA PRIVATE KEY-----"
key_id="330026715084531546"

PROJECT_ID="330021820281431898" # SGW_Project_Cisco. The Zitadel project's Resource ID.

# ZITADEL API URL (replace if needed)
api_url="http://localhost:8080"

echo "Generating encoded JWT..."

ENCODED_JWT=$(python3 ./generate_jwt.py "${service_user_id}" "${private_key}" "${key_id}" "${api_url}")

#echo "Encoded JWT: $ENCODED_JWT"

RESPONSE=$(curl -sS --request POST \
  --url ${ZITADEL_SERVER}/oauth/v2/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
  --data "scope=openid urn:zitadel:iam:org:project:id:${PROJECT_ID}:aud" \
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

