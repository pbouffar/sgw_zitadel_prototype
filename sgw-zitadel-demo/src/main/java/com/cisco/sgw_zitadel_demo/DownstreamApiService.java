package com.cisco.sgw_zitadel_demo;

import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class DownstreamApiService {

    private final WebClient webClient;
    private final OAuth2AuthorizedClientManager authorizedClientManager;
    private final String clientRegistrationId; // Store the ID, not the full object if not needed elsewhere
    private final String clientRegistrationName = "so-mock-client";
    private final String downstreamApiUrl = "http://localhost:8100/secured";

    // Constructor injection
    public DownstreamApiService(WebClient.Builder webClientBuilder,
                                OAuth2AuthorizedClientManager authorizedClientManager,
                                ClientRegistrationRepository clientRegistrationRepository) {
        this.authorizedClientManager = authorizedClientManager;

        // Retrieve the ClientRegistration by its ID (from application.yml)
        ClientRegistration clientRegistration = clientRegistrationRepository.findByRegistrationId(clientRegistrationName);
        if (clientRegistration == null) {
            throw new IllegalStateException("Client registration '" + clientRegistrationName + "' not found. Check application.yml.");
        }
        this.clientRegistrationId = clientRegistration.getRegistrationId(); // Store the ID

        // Build WebClient. We will add the OAuth2 token manually using the authorizedClientManager.
        this.webClient = webClientBuilder.build();
    }

    public String callDownstreamApi() {
        // No need for null check on clientRegistrationId here, as it's checked in the constructor

        // 1. Authorize (obtain) the OAuth2 client (which includes the access token)
        OAuth2AuthorizeRequest authorizeRequest = OAuth2AuthorizeRequest.withClientRegistrationId(this.clientRegistrationId) // CORRECTED LINE
                .principal("my-client-app") // A dummy principal name for client credentials flow
                .build();

        OAuth2AuthorizedClient authorizedClient = this.authorizedClientManager.authorize(authorizeRequest);

        if (authorizedClient == null) {
            throw new IllegalStateException("Authorization failed for client '" + this.clientRegistrationId + "'.");
        }

        // 2. Use the access token to call the downstream API
        String accessToken = authorizedClient.getAccessToken().getTokenValue();
        System.out.println("Obtained Access Token for Downstream API: " + accessToken.substring(0, Math.min(accessToken.length(), 20)) + "...");

        return webClient.get()
                .uri(downstreamApiUrl)
                .header("Authorization", "Bearer " + accessToken) // Attach the bearer token
                .retrieve()
                .bodyToMono(String.class)
                .block(); // Block for simplicity, use reactive in production
    }    
}