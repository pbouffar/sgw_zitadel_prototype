# sgw-zitadel-demo (a.k.a SGW Mock)

This details the development of a **Spring Boot 3.5.3 REST API** (sgw-zitadel-demo) designed to act as a **OAuth 2.0 Resource Server** capable of validating both **JWT (JSON Web Tokens)** and **opaque access tokens** simultaneously. It is designed to help test a client application's accessing the SGW's northbound API, acting as a OAuth 2.0 Resource Server, using the OAuth v2 framework with a Authorization Server (Zitadel) for user authentication. 

The application is capable of basic JWT local validation and token introspection for opaque tokens. A central challenge was enabling simultaneous support for both token types within a single application, which was ultimately achieved through the implementation of a custom `HybridTokenAuthenticationProvider`.

The application was extended to act as an **OAuth 2.0 Client**, demonstrating how to obtain access tokens via the **Client Credentials Grant** and use Spring's `WebClient` with `OAuth2AuthorizedClientManager` to securely call a downstream REST API (so-mock). This involved adding the `spring-boot-starter-oauth2-client` and `spring-boot-starter-webflux` dependencies and configuring the client registration.

# so-mock (a.k.a SO Mock)

This details the development of a **Spring Boot 3.5.3 REST API** (so-mock) designed to act as a **OAuth 2.0 Resource Server** capable of validating both **JWT (JSON Web Tokens)** and **opaque access tokens** simultaneously. It is designed to test the SGW Mock southbound API, acting as a OAuth 2.0 Client, accessing the SO Mock API.

Just like SGW Mock, this application is capable of basic JWT local validation and token introspection for opaque tokens. A central challenge was enabling simultaneous support for both token types within a single application, which was ultimately achieved through the implementation of a custom `HybridTokenAuthenticationProvider`.

# client_scripts (a.k.a Client Application)

These bash script automate a process of obtaining an OAuth 2.0 access token and then using it to access protected resources, as well as demonstrating access to public resources.

All scripts behave as follow with minor differences in the way access tokens are obtained and verified:

1. It sends a POST request to the ZITADEL server's /oauth/v2/token endpoint to obtain an access token.
2. It parses the JSON response from the token endpoint to extract the access_token.
3. It then makes a GET request to the /secured endpoint of the SGW Mock endpoint. Authentication is required to access this endpoint.
4. Finally, it makes another GET request to the /public/hello endpoint on the SGW Mock endpoint. No authentication is required.

# Zitadel (Authorization Server)

Zitadel provides the Authorization Server functionalities required to support the OAuth 2.0 flows.

## Install Zitadel on linux

Reference: https://zitadel.com/docs/self-hosting/deploy/linux 

Note: This installation assumes you already have PostGres installed and running on your system. Hence, I have omitted the directions to install it (recommended by Zitadel).


```
~/code/zitadel_prototype/zitadel_install  LATEST=$(curl -i https://github.com/zitadel/zitadel/releases/latest | grep location: | cut -d '/' -f 8 | tr -d '\r'); ARCH=$(uname -m); case $ARCH in armv5*) ARCH="armv5";; armv6*) ARCH="armv6";; armv7*) ARCH="arm";; aarch64) ARCH="arm64";; x86) ARCH="386";; x86_64) ARCH="amd64";;  i686) ARCH="386";; i386) ARCH="386";; esac; wget -c https://github.com/zitadel/zitadel/releases/download/$LATEST/zitadel-linux-$ARCH.tar.gz -O - | tar -xz && sudo mv zitadel-linux-$ARCH/zitadel /usr/local/bin
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
--2025-07-17 09:42:20--  https://github.com/zitadel/zitadel/releases/download/v3.3.2/zitadel-linux-amd64.tar.gz
Resolving github.com (github.com)... 140.82.112.3
Connecting to github.com (github.com)|140.82.112.3|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://release-assets.githubusercontent.com/github-production-release-asset/247714750/72da8b42-3ab1-4cbd-8d56-6f7f00f52a93?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-07-17T14%3A23%3A48Z&rscd=attachment%3B+filename%3Dzitadel-linux-amd64.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-07-17T13%3A22%3A55Z&ske=2025-07-17T14%3A23%3A48Z&sks=b&skv=2018-11-09&sig=OonG%2Boj2bM1cJpw0IDhsXv6tLJmFPfi%2FuOoclKMb5VQ%3D&jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc1Mjc2MDA0MCwibmJmIjoxNzUyNzU5NzQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.7bKuscSUPGHzuVnmfV7hBu-GlSF6CirMVvmerauC-t0&response-content-disposition=attachment%3B%20filename%3Dzitadel-linux-amd64.tar.gz&response-content-type=application%2Foctet-stream [following]
--2025-07-17 09:42:20--  https://release-assets.githubusercontent.com/github-production-release-asset/247714750/72da8b42-3ab1-4cbd-8d56-6f7f00f52a93?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-07-17T14%3A23%3A48Z&rscd=attachment%3B+filename%3Dzitadel-linux-amd64.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-07-17T13%3A22%3A55Z&ske=2025-07-17T14%3A23%3A48Z&sks=b&skv=2018-11-09&sig=OonG%2Boj2bM1cJpw0IDhsXv6tLJmFPfi%2FuOoclKMb5VQ%3D&jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc1Mjc2MDA0MCwibmJmIjoxNzUyNzU5NzQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.7bKuscSUPGHzuVnmfV7hBu-GlSF6CirMVvmerauC-t0&response-content-disposition=attachment%3B%20filename%3Dzitadel-linux-amd64.tar.gz&response-content-type=application%2Foctet-stream
Resolving release-assets.githubusercontent.com (release-assets.githubusercontent.com)... 185.199.110.133, 185.199.111.133, 185.199.108.133, ...
Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 46559071 (44M) [application/octet-stream]
Saving to: ‘STDOUT’
-                                                    100%[=====================================================================================================================>]  44.40M  28.3MB/s    in 1.6s    
2025-07-17 09:42:22 (28.3 MB/s) - written to stdout [46559071/46559071]
[sudo] password for pbouffar: 
 ~/code/zitadel_prototype/zitadel_install
```

## Run Zitadel

Since you may already have PostGres installed and running, you may need to change the `ZITADEL_DATABASE_POSTGRES_PORT`, `ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME` and `ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD` to match your system.


```
 ~/code/zitadel_prototype/zitadel_install  ZITADEL_DATABASE_POSTGRES_HOST=localhost ZITADEL_DATABASE_POSTGRES_PORT=5433 ZITADEL_DATABASE_POSTGRES_DATABASE=zitadel ZITADEL_DATABASE_POSTGRES_USER_USERNAME=zitadel ZITADEL_DATABASE_POSTGRES_USER_PASSWORD=zitadel ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE=disable ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME=postgres ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD=admin@123 ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE=disable ZITADEL_EXTERNALSECURE=false zitadel start-from-init --masterkey "MasterkeyNeedsToHave32Characters" --tlsMode disabled
INFO[0000] initialization started                        caller="/home/runner/work/zitadel/zitadel/cmd/initialise/init.go:70"
INFO[0000] verify user                                   caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_user.go:40" username=zitadel
INFO[0000] verify database                               caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_database.go:40" database=zitadel
INFO[0000] verify grant                                  caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_grant.go:35" database=zitadel user=zitadel
INFO[0000] verify zitadel                                caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_zitadel.go:80" database=zitadel
INFO[0000] verify system                                 caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_zitadel.go:46"
INFO[0000] verify encryption keys                        caller="/home/runner/work/zitadel/zitadel/cmd/initialise/verify_zitadel.go:51"
...
# OUTPUT OMITTED
...
INFO[0002] setup completed                               caller="/home/runner/work/zitadel/zitadel/cmd/setup/setup.go:117"
  _____  ___   _____      _      ____    _____   _
 |__  / |_ _| |_   _|    / \    |  _ \  | ____| | |
   / /   | |    | |     / _ \   | | | | |  _|   | |
  / /_   | |    | |    / ___ \  | |_| | | |___  | |___
 /____| |___|   |_|   /_/   \_\ |____/  |_____| |_____|
 ===============================================================
 Version          	: v3.3.2
 TLS enabled      	: false
 External Secure 	: false
 Machine Id Method	: Private Ip
 Console URL      	: http://localhost:8080/ui/console
 Health Check URL 	: http://localhost:8080/debug/healthz
 Warning: you're using plain http without TLS. Be aware this is 
 not a secure setup and should only be used for test systems.         
 Visit: https://zitadel.com/docs/self-hosting/manage/tls_modes    
 ===============================================================
INFO[0002] auth request cache disabled                   caller="/home/runner/work/zitadel/zitadel/internal/auth_request/repository/cache/cache.go:31" error="must provide a positive size"
INFO[0002] auth request cache disabled                   caller="/home/runner/work/zitadel/zitadel/internal/auth_request/repository/cache/cache.go:36" error="must provide a positive size"
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/authorize
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/device_authorization
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/token
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/introspect
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oidc/v1/userinfo
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/revoke
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oidc/v1/end_session
time=2025-07-17T10:03:07.281-04:00 level=INFO msg="registered route" endpoint=/oauth/v2/keys
INFO[0002] server is listening on [::]:8080              caller="/home/runner/work/zitadel/zitadel/cmd/start/start.go:638"
```

Then visit:

- Console URL      	: http://localhost:8080/ui/console
- Health Check URL 	: http://localhost:8080/debug/healthz

Use the following credentials:

- username: zitadel-admin@zitadel.localhost
- password: Password1!

Note: On first login, Zitadel will ask you to change your password. Don’t forget it.


# Test Setup

![Test-Setup](./documentation/test_setup.PNG)
 
