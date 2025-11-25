package com.example.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.ClientHttpRequestFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

/**
 * Configuration professionnelle pour Khan Academy API
 * Architecture Senior avec gestion des timeouts et retry
 */
@Configuration
@ConfigurationProperties(prefix = "khan-academy")
@Data
public class KhanAcademyConfig {

    private String baseUrl = "https://www.khanacademy.org/api/v1";
    private Integer connectTimeout = 5000; // 5 secondes
    private Integer readTimeout = 10000;   // 10 secondes
    private Integer maxRetries = 3;
    private Boolean cacheEnabled = true;
    private Integer cacheDurationMinutes = 60;

    /**
     * RestTemplate optimisé pour Khan Academy
     * avec timeouts configurables
     */
    @Bean(name = "khanAcademyRestTemplate")
    public RestTemplate khanAcademyRestTemplate() {
        RestTemplate restTemplate = new RestTemplate(clientHttpRequestFactory());
        
        // Ajouter des intercepteurs pour le logging (optionnel)
        restTemplate.getInterceptors().add((request, body, execution) -> {
            // Log des requêtes pour le debugging
            System.out.println("🔍 Khan Academy Request: " + request.getURI());
            return execution.execute(request, body);
        });
        
        return restTemplate;
    }

    /**
     * Configuration des timeouts HTTP
     */
    private ClientHttpRequestFactory clientHttpRequestFactory() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectTimeout);
        factory.setReadTimeout(readTimeout);
        return factory;
    }
}