package com.cisco.sgw_zitadel_demo;

import jakarta.ws.rs.ApplicationPath;
import org.glassfish.jersey.server.ResourceConfig;
import org.springframework.stereotype.Component;


@Component
@ApplicationPath("/")
public class JerseyConfig extends ResourceConfig {
    public JerseyConfig() {
        // Register your JAX-RS resource classes here
        // You can register individual classes:
        //register(DemoController.class);
        // Or, if you have many, you can scan packages (recommended for larger apps):
        packages("com.cisco.sgw_zitadel_demo"); // Assuming your JAX-RS controllers are in this subpackage
    }
}