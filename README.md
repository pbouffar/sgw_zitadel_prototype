- [sgw-zitadel-demo (a.k.a SGW Mock)](#sgw-zitadel-demo-aka-sgw-mock)
  - [Build and Run SGW Mock](#build-and-run-sgw-mock)
  - [application.yml](#applicationyml)
  - [SecurityConfig.java](#securityconfigjava)
  - [DemoController.java](#democontrollerjava)
- [so-mock (a.k.a SO Mock)](#so-mock-aka-so-mock)
- [client\_scripts (a.k.a Client Application)](#client_scripts-aka-client-application)
- [Zitadel (Authorization Server)](#zitadel-authorization-server)
  - [Install Zitadel on linux](#install-zitadel-on-linux)
  - [Run Zitadel](#run-zitadel)
  - [Setup in Zitadel](#setup-in-zitadel)
    - [Create an Organization in Zitadel](#create-an-organization-in-zitadel)
    - [Create a Project in Zitadel](#create-a-project-in-zitadel)
    - [Create Applications in Zitadel](#create-applications-in-zitadel)
      - [Update SGW Mock and SO Mock application.yml](#update-sgw-mock-and-so-mock-applicationyml)
    - [Create Service Users in Zitadel](#create-service-users-in-zitadel)
    - [Configure service user for the Client Application in Zitadel](#configure-service-user-for-the-client-application-in-zitadel)
- [Testing](#testing)
  - [Test Setup](#test-setup)
  - [Test Strategy](#test-strategy)
    - [How to test SGW access to southbound API](#how-to-test-sgw-access-to-southbound-api)


# sgw-zitadel-demo (a.k.a SGW Mock)

This details the development of a **Spring Boot 3.5.3 REST API** (sgw-zitadel-demo) designed to act as a **OAuth 2.0 Resource Server** capable of validating both **JWT (JSON Web Tokens)** and **opaque access tokens** simultaneously. It is designed to help test a client application's accessing the SGW's northbound API, acting as a OAuth 2.0 Resource Server, using the OAuth v2 framework with a Authorization Server (Zitadel) for user authentication. 

The application is capable of basic JWT local validation and token introspection for opaque tokens. A central challenge was enabling simultaneous support for both token types within a single application, which was ultimately achieved through the implementation of a custom `HybridTokenAuthenticationProvider`.

The application was extended to act as an **OAuth 2.0 Client**, demonstrating how to obtain access tokens via the **Client Credentials Grant** and use Spring's `WebClient` with `OAuth2AuthorizedClientManager` to securely call a downstream REST API (so-mock). This involved adding the `spring-boot-starter-oauth2-client` and `spring-boot-starter-webflux` dependencies and configuring the client registration.

## Build and Run SGW Mock

```
mvn clean install
mvn spring-boot:run 
```

## application.yml

This file will configure your application as an OAuth 2.0 Resource Server. 

The file specifies the `issuer-uri` which is the base URL of your OAuth 2.0 Authorization Server, which issues the JWTs. Spring Security will use this URI to discover the JWKS (JSON Web Key Set) endpoint and validate the incoming JWTs. http://localhost:8080 is the actual `issuer-uri` of your Zitadel Authorization Server. 

The file also specifies the `introspection-uri` and credentials to perform opaque access token validation via the Authorization Server’s introspection API.

## SecurityConfig.java

Defines the security filter chain for your application. This class will enable OAuth 2.0 Resource Server capabilities.

This configuration supports local validation of JWT access token and Zitadel’s introspection endpoint for opaque token (but also JWT token validation). The configuration specifies .authenticationProvider(hybridTokenAuthenticationProvider) which provides the mechanism to support both token validation methods. This tells Spring Security to treat the application as an OAuth 2.0 Resource Server that validates JSON Web Tokens (JWTs) or opaque token (through introspection). 

When using JWTs, the resource server validates the access token locally by verifying its signature using public keys obtained from the Authorization Server's JWKS (JSON Web Key Set) endpoint (which is discovered via the issuer-uri configured in application.yml). It also checks claims like expiration, issuer, and audience.

## DemoController.java

A simple REST controller with endpoints to test the OAuth 2.0 authentication.

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

## Setup in Zitadel

### Create an Organization in Zitadel

This step consist of creating the `Cisco` organisation in Zitadel.

1. In Zitadel, at the top-left of the page, click on the `up/down` arrows on the left of the `Zitadel` organisation.
2. Select **+ New Organisation**.
3. Enter the **Name** `Cisco`.
4. Click **Create**.

Then go back to clicking the up/down arrows on the left of the `Zitadel` organisation and select the `Cisco` organisation.

### Create a Project in Zitadel

This step consist of creating the `SGW_Project_Cisco` project in the `Cisco` Zitadel organisation.

1. In Zitadel, click on **Create New Project** in the **Projects** tab.
2. Enter the **Name** `SGW_Project_Cisco`.
3. Click **Continue**.

You can now proceed to create the Zitadel Applications.

### Create Applications in Zitadel

This step consist of create two Application inside the `SGW_Project_Cisco` Zitadel project. 

The following two Applications need to be created :
- `SGW_Northbound_API`: This application defines the SGW Mock application's northbound API.
- `SO Mock API`: This application defines the SO Mock application's northbound API.

When creating an Application, it is important to take note of the following information for each: **client-id** and **client-secret**. This information needs to be saved to the `application.yml` file of each Sprint Boot application, i.e. `sgw-zitadel-demo` and `so-mock`.

Follow these steps to create both application:

1. In Zitadel, select the `SGW_Project_Cisco` project in the **Projects** tab.
2. Select **APPLICATIONS** > **New**.  
3. Enter the **NAME OF THE APPLICATION**. Use the names suggested here above.
4. Select **API** for the **TYPE OF APPLICATION**.
5. Click **Continue**.
6. Select **BASIC** when asked to **Enter Your Application Details Step by Step**.
7. Click **Continue**.
8. Click **Create**.
9. **Copy and save** the application's **ClientId** and **ClientSecret**. They will be used (see below) to populate the respective `application.yml` file of each application.
10. Click **Close**.

#### Update SGW Mock and SO Mock application.yml

Update the `sgw-zitadel-demo` application's `application.yml` file `client-id` and `client-secret` fields (as shown below) with the `SGW_Northbound_API`'s **ClientId** and **ClientSecret** saved earlier when the Application was created in Zitadel.

Similarly, update the `so-mock` application's `application.yml` file `client-id` and `client-secret` fields (as shown below) with the `SO Mock API`'s **ClientId** and **ClientSecret** saved earlier when the Application was created in Zitadel.

```yml
        opaquetoken:
          introspection-uri: http://localhost:8080/oauth/v2/introspect
          client-id: <ClientId>
          client-secret: <ClientSecret>          
```

This configuration is what allows a Spring Boot application to authenticate with Zitadel and access its API to perform, for example, token introspection.

### Create Service Users in Zitadel

1. In Zitadel, select the **Service Users** project in the **Users** tab.
2. Click the **New** button.
3. In the **CREATE A NEW USER** page, enter the **User Name**, **Name** and **Description**.
4. Select one of the following **Access Token Type**:
    - **Bearer**: Uses an opaque access token to authenticate with a resource server's API. The resource server needs to call the authentication server's token introspection endpoint to validate the access token.
    - **JWT**: Uses an JWT access token to authenticate with a resource server's API. The resource server locally validates the access token.
5. Click the **Actions** button.
6. Select **Generate Client Secret**.
7. Save the service user's **ClientId** and **ClientSecret**.
8. Click **Close**.

### Configure service user for the Client Application in Zitadel

1. Login to Zitadel via http://localhost:8080/ui/console.

2. Follow the instructions at https://zitadel.com/docs/guides/integrate/service-users/client-credentials#1-create-a-service-user-with-a-client-secret  .

3. In the **SERVICE USER DETAILS**, select **Access Token Type** to be JWT. This will ensure we get a Jason Web Token (JWT) as an access token for the user. Choosing *Bearer* will return an opaque token as an access token.

4. Make sure to copy in particular the ClientSecret when you reach the step **Generate Client Secret**. You won't be able to retrieve it again. If you lose it, you will have to generate a new one.


# Testing 

## Test Setup

![Test-Setup](./documentation/test_setup.PNG)
 
## Test Strategy

### How to test SGW access to southbound API

1. Set up SO Mock (the Downstream Resource Server): You'll need another Spring Boot application (or any API) running on http://localhost:8100  that is also configured as an OAuth 2.0 Resource Server and protects its /secured endpoint.
2. Configure Authorization Server (Zitadel):
- Ensure Zitadel (your Authorization Server) is running on http://localhost:8080.
- Register a new client application with Zitadel for the SGW app (the one acting as a client). This new client should use the Client Credentials grant type and have the client-id (my-client-app-id) and client-secret (my-client-app-secret) you configured.
- Ensure this client is authorized for the scopes (openid, profil) that the downstream API expects.
3. Run Both Applications: Start your SGW application and the SO Mock resource server.
4. Trigger the Call: Access http://localhost:8090/call-downstream in your browser or via curl.

SGW will then:

1. Request an access token from Zitadel http://localhost:8080 using its my-client-app-id and my-client-app-secret.
2. Receive the access token.
3. Make an HTTP GET request to http://localhost:8100/secured, attaching the obtained access token in the Authorization: Bearer header.
4. Return the response from the downstream API.