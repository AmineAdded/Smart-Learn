class ApiConfig {
  // URL de base de votre API
  // Remplacez cette URL par celle de votre tunnel Cloudflare
<<<<<<< HEAD
  static const String baseUrl = 'https://thousand-stories-skills-conf.trycloudflare.com';
=======
  static const String baseUrl = 'https://paper-discipline-cleared-ceremony.trycloudflare.com';
>>>>>>> aya

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