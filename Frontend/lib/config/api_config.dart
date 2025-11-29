class ApiConfig {
  // URL de base de votre API
  // Remplacez cette URL par celle de votre tunnel Cloudflare
  static const String baseUrl = 'https://manually-wear-yoga-hall.trycloudflare.com';

  // Timeout pour les requêtes HTTP (en secondes)
  static const int timeoutSeconds = 30;

  // Configuration supplémentaire si nécessaire
  static const String apiVersion = 'v1';

  // Headers communs pour toutes les requêtes
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}