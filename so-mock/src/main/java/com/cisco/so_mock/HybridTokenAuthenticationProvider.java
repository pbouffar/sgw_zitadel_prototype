package com.cisco.so_mock;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2AuthenticatedPrincipal;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.server.resource.authentication.BearerTokenAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.BearerTokenAuthentication;
import org.springframework.security.oauth2.server.resource.introspection.OpaqueTokenIntrospector;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Arrays;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory; 

@Component
public class HybridTokenAuthenticationProvider implements AuthenticationProvider {

    private static final Logger logger = LoggerFactory.getLogger(HybridTokenAuthenticationProvider.class);
    
    public static final String ZITADEL_ROLES_CLAIM = "urn:zitadel:iam:org:project:roles";

    private final JwtDecoder jwtDecoder;
    private final OpaqueTokenIntrospector opaqueTokenIntrospector;

    public HybridTokenAuthenticationProvider(JwtDecoder jwtDecoder, OpaqueTokenIntrospector opaqueTokenIntrospector) {
        logger.debug("HybridTokenAuthenticationProvider: jwtDecoder -> " + jwtDecoder);
        this.jwtDecoder = jwtDecoder;
        logger.debug("HybridTokenAuthenticationProvider: opaqueTokenIntrospector -> " + opaqueTokenIntrospector);
        this.opaqueTokenIntrospector = opaqueTokenIntrospector;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        BearerTokenAuthenticationToken bearerToken = (BearerTokenAuthenticationToken) authentication;
        String tokenValue = bearerToken.getToken(); // Rename to tokenValue to avoid confusion with OAuth2AccessToken object

        //logger.debug("authenticate");
        System.out.println("HybridTokenAuthenticationProvider: Attempting to authenticate token: " + tokenValue.substring(0, Math.min(tokenValue.length(), 20)) + "...");

        // 1. Try JWT validation first (local and faster)
        try {
            Jwt jwt = this.jwtDecoder.decode(tokenValue);
            Collection<GrantedAuthority> authorities = extractAuthoritiesFromJwt(jwt);
            JwtAuthenticationToken jwtAuthToken = new JwtAuthenticationToken(jwt, authorities);
            System.out.println("HybridTokenAuthenticationProvider: Successfully authenticated as JWT. Principal: " + jwt.getSubject());
            return jwtAuthToken;
        } catch (JwtException e) {
            System.out.println("JWT validation failed, attempting opaque token introspection: " + e.getMessage());
        }

        // 2. If JWT validation failed, try opaque token introspection
        try {

            System.out.println("HybridTokenAuthenticationProvider: Performing token introspection...");

            // Introspect the token to get the principal and its attributes
            OAuth2AuthenticatedPrincipal principal = this.opaqueTokenIntrospector.introspect(tokenValue);

            System.out.println("HybridTokenAuthenticationProvider: Introspection successful. Principal name: " + principal.getName() + ", Attributes: " + principal.getAttributes());

            // Extract authorities from the principal's attributes (e.g., 'scope' claim from introspection response)
            Collection<GrantedAuthority> authorities = extractAuthoritiesFromIntrospectionPrincipal(principal);

            // Create an OAuth2AccessToken object from the token value and principal attributes
            // The token type is usually "Bearer"
            // The expiresAt is typically from the 'exp' claim in the introspection response
            // The issuedAt is typically from the 'iat' claim in the introspection response
            OAuth2AccessToken accessToken = new OAuth2AccessToken(
                    OAuth2AccessToken.TokenType.BEARER,
                    tokenValue,
                    (Instant) principal.getAttributes().get("iat"), // issuedAt
                    (Instant) principal.getAttributes().get("exp")  // expiresAt
            );

            // Construct the BearerTokenAuthentication with all required arguments
            return new BearerTokenAuthentication(principal, accessToken, authorities);

        } catch (OAuth2AuthenticationException e) {
            System.out.println("Opaque token introspection failed: " + e.getMessage());
            throw e;
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        System.out.println(">>> HybridTokenAuthenticationProvider: supports() called for type: " + authentication.getName());
        System.out.println(">>> HybridTokenAuthenticationProvider: Class of 'authentication' object: " + authentication.getName() + " loaded by: " + authentication.getClassLoader());
        System.out.println(">>> HybridTokenAuthenticationProvider: BearerTokenAuthenticationToken.class: " + BearerTokenAuthenticationToken.class.getName() + " loaded by: " + BearerTokenAuthenticationToken.class.getClassLoader());

        boolean result = BearerTokenAuthenticationToken.class.isAssignableFrom(authentication);

        System.out.println(">>> HybridTokenAuthenticationProvider: supports() returning " + result);
        return result;
    }

    // Helper method to extract authorities from JWT claims
    private Collection<GrantedAuthority> extractAuthoritiesFromJwt(Jwt jwt) {
        logger.debug("extractAuthoritiesFromJwt");
        Object scopes = jwt.getClaims().get("scope");
        return parseScopesToAuthorities(scopes);
    }

    // Helper method to extract authorities from OAuth2IntrospectionAuthenticatedPrincipal attributes
    private Collection<GrantedAuthority> extractAuthoritiesFromIntrospectionPrincipal(OAuth2AuthenticatedPrincipal principal) {
        logger.debug("extractAuthoritiesFromIntrospectionPrincipal");

        var authorities = new HashSet<GrantedAuthority>();

        HashMap<String, Object> claims = principal.getAttribute(ZITADEL_ROLES_CLAIM);
        if (claims == null) {
            return authorities;
        }

        claims.keySet().forEach(role -> {
            authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
        });

        return authorities;        
    }

    // Common helper to parse scope string/collection into GrantedAuthorities
    private Collection<GrantedAuthority> parseScopesToAuthorities(Object scopes) {
        logger.debug("parseScopesToAuthorities");
        if (scopes instanceof String) {
            return Arrays.stream(((String) scopes).split(" "))
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList());
        } else if (scopes instanceof Collection) {
            return ((Collection<?>) scopes).stream()
                    .map(Object::toString)
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList());
        }
        return Collections.emptyList();
    }
}