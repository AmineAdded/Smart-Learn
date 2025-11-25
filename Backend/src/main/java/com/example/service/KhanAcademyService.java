package com.example.service;

import com.example.dto.khan.KhanTopicDTO;
import com.example.model.Video;
import com.example.repository.VideoRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Service Khan Academy - Architecture Senior
 * 
 * Fonctionnalités:
 * - Retry automatique en cas d'échec
 * - Cache intelligent
 * - Mapping professionnel des données
 * - Gestion d'erreurs robuste
 * - Logging détaillé
 * 
 * @author Votre Nom
 * @version 2.0
 */
@Service
@Slf4j
public class KhanAcademyService {

    private static final String API_BASE = "https://www.khanacademy.org/api/v1";
    
    // Topics Khan Academy mappés par catégorie
    private static final Map<String, String> CATEGORY_TO_TOPIC = Map.of(
        "Mathématiques", "math",
        "Physique", "science/physics",
        "Chimie", "science/chemistry",
        "Biologie", "science/biology",
        "Informatique", "computing",
        "Économie", "economics-finance-domain",
        "Sciences", "science"
    );

    @Autowired
    @Qualifier("khanAcademyRestTemplate")
    private RestTemplate restTemplate;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * Recherche des vidéos par catégorie
     * Avec cache pour optimiser les performances
     * 
     * @param category Catégorie éducative
     * @param maxResults Nombre max de résultats
     * @return Liste de vidéos
     */
    @Cacheable(value = "khan-videos", key = "#category + '-' + #maxResults")
    @Retryable(
        value = {RestClientException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2)
    )
    public List<Video> searchVideosByCategory(String category, Integer maxResults) {
        log.info("🔍 Recherche Khan Academy: catégorie={}, max={}", category, maxResults);
        
        String topicSlug = CATEGORY_TO_TOPIC.getOrDefault(category, "math");
        
        try {
            // Récupérer le topic principal
            KhanTopicDTO topic = getTopicBySlug(topicSlug);
            
            if (topic == null) {
                log.warn("⚠️ Topic non trouvé: {}", topicSlug);
                return Collections.emptyList();
            }
            
            // Extraire toutes les vidéos du topic
            List<Video> videos = extractVideosFromTopic(topic, category, maxResults);
            
            log.info("✅ Trouvé {} vidéos Khan Academy pour {}", videos.size(), category);
            return videos;
            
        } catch (HttpClientErrorException e) {
            log.error("❌ Erreur HTTP Khan Academy: {} - {}", e.getStatusCode(), e.getMessage());
            throw new RuntimeException("Erreur lors de la récupération des vidéos Khan Academy", e);
        } catch (Exception e) {
            log.error("❌ Erreur inattendue Khan Academy: {}", e.getMessage(), e);
            return Collections.emptyList();
        }
    }

    /**
     * Récupère un topic Khan Academy par son slug
     */
    private KhanTopicDTO getTopicBySlug(String slug) {
        String url = API_BASE + "/topic/" + slug;
        
        try {
            String response = restTemplate.getForObject(url, String.class);
            return objectMapper.readValue(response, KhanTopicDTO.class);
        } catch (Exception e) {
            log.error("Erreur parsing topic {}: {}", slug, e.getMessage());
            return null;
        }
    }

    /**
     * Extrait récursivement les vidéos d'un topic
     * Architecture récursive pour parcourir l'arbre de contenus
     */
    private List<Video> extractVideosFromTopic(KhanTopicDTO topic, String category, Integer maxResults) {
        List<Video> videos = new ArrayList<>();
        
        if (topic == null) {
            return videos;
        }
        
        // Parcourir les enfants du topic
        List<JsonNode> children = getTopicChildren(topic);
        
        for (JsonNode child : children) {
            if (videos.size() >= maxResults) {
                break;
            }
            
            try {
                String kind = child.has("kind") ? child.get("kind").asText() : "";
                
                if ("Video".equals(kind)) {
                    Video video = parseKhanVideo(child, category);
                    if (video != null) {
                        videos.add(saveOrUpdateVideo(video));
                    }
                } else if ("Topic".equals(kind)) {
                    // Récursion pour les sous-topics
                    String childSlug = child.has("slug") ? child.get("slug").asText() : null;
                    if (childSlug != null && videos.size() < maxResults) {
                        KhanTopicDTO subTopic = getTopicBySlug(childSlug);
                        videos.addAll(extractVideosFromTopic(subTopic, category, maxResults - videos.size()));
                    }
                }
            } catch (Exception e) {
                log.warn("⚠️ Erreur parsing enfant: {}", e.getMessage());
            }
        }
        
        return videos;
    }

    /**
     * Récupère les enfants d'un topic (gestion de plusieurs formats d'API)
     */
    private List<JsonNode> getTopicChildren(KhanTopicDTO topic) {
        List<JsonNode> children = new ArrayList<>();
        
        try {
            JsonNode topicNode = objectMapper.valueToTree(topic);
            
            // Khan Academy peut retourner "children" ou "child_data"
            if (topicNode.has("children") && topicNode.get("children").isArray()) {
                topicNode.get("children").forEach(children::add);
            }
            
            if (topicNode.has("child_data") && topicNode.get("child_data").isArray()) {
                topicNode.get("child_data").forEach(children::add);
            }
            
        } catch (Exception e) {
            log.warn("Erreur extraction enfants: {}", e.getMessage());
        }
        
        return children;
    }

    /**
     * Parse une vidéo Khan Academy en objet Video
     * Mapping professionnel avec gestion de tous les cas
     */
    private Video parseKhanVideo(JsonNode node, String category) {
        try {
            // Extraction des données avec fallbacks
            String youtubeId = extractField(node, "youtube_id", "translated_youtube_id");
            
            if (youtubeId == null || youtubeId.isEmpty()) {
                log.debug("Vidéo sans youtube_id, ignorée");
                return null;
            }
            
            String title = extractField(node, "translated_title", "title");
            String description = extractField(node, "translated_description", "description");
            
            // Durée en secondes
            Integer duration = node.has("duration") ? node.get("duration").asInt() : 600;
            
            // URL Khan Academy
            String kaUrl = node.has("ka_url") ? node.get("ka_url").asText() : "";
            
            // Thumbnail
            String thumbnailUrl = node.has("image_url") 
                ? node.get("image_url").asText()
                : "https://i.ytimg.com/vi/" + youtubeId + "/hqdefault.jpg";
            
            // Keywords pour les tags
            String tags = extractTags(node);
            
            return Video.builder()
                    .youtubeId(youtubeId)
                    .title(title != null ? title : "Vidéo Khan Academy")
                    .description(description != null ? description : "Contenu éducatif Khan Academy")
                    .thumbnailUrl(thumbnailUrl)
                    .channelTitle("Khan Academy")
                    .duration(duration)
                    .category(category)
                    .difficulty(determineDifficulty(kaUrl, title))
                    .viewCount(0)
                    .favoriteCount(0)
                    .tags(tags)
                    .isActive(true)
                    .isFeatured(true) // Khan Academy = contenu de qualité
                    .build();
                    
        } catch (Exception e) {
            log.error("❌ Erreur parsing vidéo: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Extrait un champ avec fallback (multilingue)
     */
    private String extractField(JsonNode node, String primaryField, String fallbackField) {
        if (node.has(primaryField) && !node.get(primaryField).asText().isEmpty()) {
            return node.get(primaryField).asText();
        }
        if (node.has(fallbackField) && !node.get(fallbackField).asText().isEmpty()) {
            return node.get(fallbackField).asText();
        }
        return null;
    }

    /**
     * Extrait les tags/keywords
     */
    private String extractTags(JsonNode node) {
        if (node.has("keywords") && node.get("keywords").isArray()) {
            List<String> keywords = new ArrayList<>();
            node.get("keywords").forEach(k -> keywords.add(k.asText()));
            return String.join(",", keywords);
        }
        return "khan-academy,éducation";
    }

    /**
     * Détermine la difficulté basée sur l'URL et le titre
     */
    private String determineDifficulty(String kaUrl, String title) {
        String combined = (kaUrl + " " + title).toLowerCase();
        
        if (combined.contains("early-math") || combined.contains("basic") || 
            combined.contains("introduction") || combined.contains("k-") ||
            combined.contains("grade-1") || combined.contains("grade-2")) {
            return "Facile";
        } else if (combined.contains("college") || combined.contains("advanced") ||
                   combined.contains("differential") || combined.contains("integral")) {
            return "Difficile";
        } else {
            return "Moyen";
        }
    }

    /**
     * Sauvegarde ou met à jour une vidéo
     * Pattern upsert professionnel
     */
    private Video saveOrUpdateVideo(Video video) {
        return videoRepository.findByYoutubeId(video.getYoutubeId())
                .map(existing -> {
                    // Mise à jour des données
                    existing.setTitle(video.getTitle());
                    existing.setDescription(video.getDescription());
                    existing.setThumbnailUrl(video.getThumbnailUrl());
                    existing.setDuration(video.getDuration());
                    existing.setTags(video.getTags());
                    log.debug("♻️ Mise à jour vidéo: {}", existing.getYoutubeId());
                    return videoRepository.save(existing);
                })
                .orElseGet(() -> {
                    log.debug("➕ Nouvelle vidéo: {}", video.getYoutubeId());
                    return videoRepository.save(video);
                });
    }

    /**
     * Récupère les vidéos populaires par domaine
     */
    @Cacheable(value = "khan-popular", key = "#domain")
    public List<Video> getPopularVideos(String domain) {
        log.info("🔥 Récupération vidéos populaires: {}", domain);
        return searchVideosByCategory(domain, 20);
    }

    /**
     * Récupère toutes les catégories disponibles
     */
    public List<String> getAvailableCategories() {
        return new ArrayList<>(CATEGORY_TO_TOPIC.keySet());
    }

    /**
     * Recherche textuelle dans Khan Academy
     * Utilise l'endpoint de recherche
     */
    @Cacheable(value = "khan-search", key = "#query + '-' + #maxResults")
    public List<Video> searchVideos(String query, Integer maxResults) {
        log.info("🔎 Recherche Khan Academy: query={}", query);
        
        String url = API_BASE + "/search?q=" + query + "&kind=Video";
        
        try {
            String response = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);
            
            List<Video> videos = new ArrayList<>();
            
            if (root.has("results") && root.get("results").isArray()) {
                for (JsonNode result : root.get("results")) {
                    if (videos.size() >= maxResults) break;
                    
                    Video video = parseKhanVideo(result, "Général");
                    if (video != null) {
                        videos.add(saveOrUpdateVideo(video));
                    }
                }
            }
            
            return videos;
            
        } catch (Exception e) {
            log.error("❌ Erreur recherche: {}", e.getMessage());
            return Collections.emptyList();
        }
    }
}