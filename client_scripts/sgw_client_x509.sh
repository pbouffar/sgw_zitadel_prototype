#!/bin/bash

# --cert client.crt: Specifies the client's public certificate.
# --key client.key:  Specifies the client's private key.
# --cacert ca.crt:   Tells curl to trust the ca.crt when verifying the server's certificate. 
#                    Without this, curl might complain about the self-signed server certificate.
# https://localhost:8443/some-authenticated-endpoint: 
#                    The URL of your application. 
#                    Replace /some-authenticated-endpoint with an actual endpoint that requires 
#                    authentication (e.g., anything not /public/**).

curl --cert client.crt --key client.key --cacert ca.crt https://localhost:8443/secured
