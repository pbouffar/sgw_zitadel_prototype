#!/bin/bash

# Create certs directory. 
mkdir -p ../sgw-zitadel-demo/src/main/resources/certs

#
# Create a Root Certificate Authority (CA)
#
echo "Creating a Root Certificate Authority (CA)..."

# Create CA private key
openssl genrsa -out ca.key 2048

# Create CA certificate (self-signed)
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=MyRootCA"

#
# Generate Server Certificate
#
echo "Generating Server Certificate..."

# Create server private key
openssl genrsa -out server.key 2048

# Create server certificate signing request (CSR)
openssl req -new -key server.key -out server.csr -subj "/CN=localhost" # Use localhost if running locally

# Sign the server CSR with your CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256

# Combine server key and certificate into a PKCS12 keystore
# This is what Spring Boot's server.ssl.key-store expects
openssl pkcs12 -export -out server.p12 -name springboot -keysig -in server.crt -inkey server.key -password pass:changeit

# Place server.p12 into src/main/resources/certs/ (create the certs folder).
echo "Copying server.p12 to ../sgw-zitadel-demo/src/main/resources/certs"
cp ./server.p12 ../sgw-zitadel-demo/src/main/resources/certs/

#
# Generate Client Certificate
#
echo "Generating Client Certificate..."

# Create client private key
openssl genrsa -out client.key 2048

# Create client certificate signing request (CSR)
openssl req -new -key client.key -out client.csr -subj "/CN=testuser" # IMPORTANT: This CN will be the username

# Sign the client CSR with your CA
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAserial ca.srl -out client.crt -days 365 -sha256

# Combine client key and certificate into a PKCS12 file (for clients like Postman/browsers)
openssl pkcs12 -export -out client.p12 -name clientcert -in client.crt -inkey client.key -password pass:changeit

echo "Copying client.crt client.key ca.crt to ../client_scripts"
cp client.crt client.key ca.crt ../client_scripts

#
# Create a Truststore for the Server
#
echo "Creating a Truststore for the Server..."

# Create a JKS truststore and import the CA certificate into it
keytool -import -trustcacerts -alias myca -file ca.crt -keystore truststore.jks -storepass changeit -noprompt

# Place truststore.jks into src/main/resources/certs/ (create the certs folder).
echo "Copying truststore.jks to ../sgw-zitadel-demo/src/main/resources/certs"
cp ./truststore.jks ../sgw-zitadel-demo/src/main/resources/certs/

# Delete generated files.
echo "Cleaning up..."
#rm ./ca.*
#rm ./client.*
#rm ./server.*
#rm ./truststore.jks

# DONE
echo "Done."

