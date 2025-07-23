package com.cisco.sgw_zitadel_demo;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.introspection.OAuth2IntrospectionAuthenticatedPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;    

@RestController
public class DemoController {

    private static final Logger logger = LoggerFactory.getLogger(DemoController.class);

    private final DownstreamApiService downstreamApiService;

    public DemoController(DownstreamApiService downstreamApiService) {
        this.downstreamApiService = downstreamApiService;
    }

    // If supporting both local access token validation and token introspection.
    @GetMapping("/secured")
    public String securedEndpoint() {        

        logger.debug("Secured endpoint called.");

        // Get the Authentication object from the SecurityContextHolder
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        System.out.println("Authentication object from SecurityContextHolder: " + authentication);
        if (authentication == null) {
            // This should ideally not happen for a @Secured endpoint, but good for debugging
            return "Error: No authentication found in SecurityContext.";
        }

        // Get the principal from the Authentication object
        Object principal = authentication.getPrincipal();

        System.out.println("Authentication type: " + authentication.getClass().getName());
        System.out.println("Authentication principal (from Authentication object): " + principal);
        if (principal != null) {
            System.out.println("Authentication principal type: " + principal.getClass().getName());
            System.out.println("Authentication authorities: " + authentication.getAuthorities());
        }

        String message;
        if (principal instanceof Jwt) {
            Jwt jwt = (Jwt) principal;
            message = "Hello, " + jwt.getSubject() + "! (Authenticated via JWT). Your scopes: " + jwt.getClaims().get("scope");
        } else if (principal instanceof OAuth2IntrospectionAuthenticatedPrincipal) {
            // If introspection was successful, the principal will be an OAuth2IntrospectionAuthenticatedPrincipal
            OAuth2IntrospectionAuthenticatedPrincipal opaquePrincipal = (OAuth2IntrospectionAuthenticatedPrincipal) principal;
            message = "Hello, " + opaquePrincipal.getName() + "! (Authenticated via Introspection). All attributes: " + opaquePrincipal.getAttributes();
        } else {
            if (principal == null) {
                logger.error("principal is null!");
                message = "Hello, unknown principal type! Principal is null.";
            } else {
                message = "Hello, unknown principal type! Principal class: " + principal.getClass().getName();
            }
        }
        return message;
    }

    @GetMapping("/public/hello")
    public String publicEndpoint() {
        logger.debug("Public endpoint called.");
        return "Hello from a public endpoint!";
    }

    // Endpoint to trigger the downstream call to the SO Mock API.
    @GetMapping("/call-downstream")
    public String callDownstreamSecuredApi() {
        logger.debug("Attempting to call downstream SO Mock API...");
        try {
            String response = downstreamApiService.callDownstreamApi();
            logger.debug("Successfully called downstream SO Mock API: " + response);
            return "Successfully called downstream SO Mock API: " + response;
        } catch (Exception e) {
            e.printStackTrace();
            return "Failed to call downstream SO Mock API: " + e.getMessage();
        }
    }    
}