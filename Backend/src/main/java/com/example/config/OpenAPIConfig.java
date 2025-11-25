package com.example.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuration Swagger/OpenAPI - Documentation professionnelle de l'API
 */
@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("📚 Education App API - Khan Academy Integration")
                        .version("2.0.0")
                        .description("""
                                # API d'Application Éducative
                                
                                ## Fonctionnalités principales
                                
                                ### 🎥 Bibliothèque Vidéo
                                - Recherche de vidéos via Khan Academy (100% gratuit)
                                - Filtrage par catégorie et difficulté
                                - Système de favoris
                                - Suivi de progression
                                
                                ### 📝 Gestion des Notes
                                - Notes personnelles avec timestamps
                                - Organisation par vidéo
                                
                                ### 📊 Statistiques
                                - Temps de visionnage
                                - Vidéos complétées
                                - Progression par catégorie
                                
                                ### 🎯 Recommandations
                                - Basées sur les intérêts de l'utilisateur
                                - Adaptées au niveau
                                
                                ## Sources de contenu
                                - **Khan Academy** : Contenu éducatif de qualité (gratuit, illimité)
                                - Base de données locale avec cache intelligent
                                
                                ## Technologies
                                - Spring Boot 3.2
                                - Spring Security avec JWT
                                - JPA/Hibernate
                                -mysql
                                - Cache Caffeine
                                - Retry automatique
                                """)
                        .contact(new Contact()
                                .name("KarouiSouha")
                                .email("karoui.souha18@gmail.com")
                                .url("https://github.com/KarouiSouha"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080")
                                .description("Serveur de développement"),
                        new Server()
                                .url("https://api.votre-app.com")
                                .description("Serveur de production")
                ));
    }
}