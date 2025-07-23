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
 
