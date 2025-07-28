package com.cisco.sgw_zitadel_demo;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationManagerResolver;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProviderBuilder;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizedClientRepository;
import org.springframework.web.reactive.function.client.WebClient; // Import WebClient
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

import java.util.Collections; // For Collections.singletonList
import java.util.stream.Collectors; // For logging 

import org.slf4j.Logger;
import org.slf4j.LoggerFactory; 

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(jsr250Enabled = true) // This is critical. It enables Spring Security to recognize and process JSR-250 annotations like @PermitAll, @RolesAllowed, and @DenyAll.
public class SecurityConfig {

    private static final Logger logger = LoggerFactory.getLogger(SecurityConfig.class);

    // Inject your custom authentication provider
    private final HybridTokenAuthenticationProvider hybridTokenAuthenticationProvider;

    public SecurityConfig(HybridTokenAuthenticationProvider hybridTokenAuthenticationProvider) {
        this.hybridTokenAuthenticationProvider = hybridTokenAuthenticationProvider;
    }
    

    // Define an AuthenticationManagerResolver bean
    // This resolver will provide the AuthenticationManager for the OAuth2 Resource Server
    @Bean
    public AuthenticationManagerResolver<HttpServletRequest> bearerTokenAuthenticationManagerResolver() {
        // Create an AuthenticationManager that ONLY uses your HybridTokenAuthenticationProvider.
        // This ensures no other default providers (like JwtAuthenticationProvider or OpaqueTokenAuthenticationProvider)
        // interfere or take precedence.
        AuthenticationManager authenticationManager = new ProviderManager(
            Collections.singletonList(hybridTokenAuthenticationProvider)
        );

        //System.out.println(">>> SecurityConfig: bearerTokenAuthenticationManagerResolver bean created. Manager instance: " + authenticationManager.getClass().getName());

        System.out.println(">>> SecurityConfig: bearerTokenAuthenticationManagerResolver bean created.");
        System.out.println(">>> SecurityConfig: AuthenticationManager contains ONLY: " +
            ((ProviderManager) authenticationManager).getProviders().stream()
                .map(p -> p.getClass().getName())
                .collect(Collectors.joining(", ")));

        // This resolver will always return the above authenticationManager for any HttpServletRequest.
        // In more complex scenarios (e.g., multi-tenancy), you might inspect the request
        // to return different managers based on issuer, etc.
        return request -> {
            System.out.println(">>> SecurityConfig: AuthenticationManagerResolver resolving for request URI: " + request.getRequestURI());
            return authenticationManager;
        };
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Disable CSRF for stateless REST APIs
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/public/**").permitAll() // Allow public access to /public endpoints
                .anyRequest().authenticated() // All other requests require authentication
            )
            // Configure oauth2ResourceServer to use your custom AuthenticationManagerResolver.
            // DO NOT call .jwt() or .opaqueToken() here, as the resolver takes precedence.
            .oauth2ResourceServer(oauth2 -> oauth2.authenticationManagerResolver(bearerTokenAuthenticationManagerResolver()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        System.out.println(">>> SecurityConfig: SecurityFilterChain bean created.");
        return http.build();
    }

    // --- OAuth2 Client Configuration Beans ---

    // Provides a WebClient.Builder for creating WebClient instances
    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }

    // Manages OAuth2 authorized clients (obtains and refreshes tokens)
    @Bean
    public OAuth2AuthorizedClientManager authorizedClientManager(
            ClientRegistrationRepository clientRegistrationRepository,
            OAuth2AuthorizedClientRepository authorizedClientRepository) {

        // Configure the types of OAuth2 grants this manager will support
        OAuth2AuthorizedClientProvider authorizedClientProvider =
                OAuth2AuthorizedClientProviderBuilder.builder()
                        .clientCredentials() // Enable Client Credentials Grant
                        .build();

        DefaultOAuth2AuthorizedClientManager authorizedClientManager =
                new DefaultOAuth2AuthorizedClientManager(
                        clientRegistrationRepository,
                        authorizedClientRepository);
        authorizedClientManager.setAuthorizedClientProvider(authorizedClientProvider);

        return authorizedClientManager;
    }    
}