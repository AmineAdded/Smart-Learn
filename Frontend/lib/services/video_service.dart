import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';
import '../models/video_note.dart';
import '../models/video_playlist.dart';
import '../models/add_xp_response.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'dart:math'; // Pour min()
import 'dart:convert';
import 'package:http/http.dart' as http;
class VideoService {
  final _authService = AuthService();

  // ========== FAVORIS AVEC XP ==========

  /// 🆕 Toggle favorite avec retour XP
  Future<Map<String, dynamic>> toggleFavorite(int videoId, bool isFavorite) async {
    try {
      final token = await _authService.getToken();
      final method = isFavorite ? 'DELETE' : 'POST';

      final response = await http.Request(
        method,
        Uri.parse('${ApiConfig.baseUrl}/api/videos/$videoId/favorite'),
      )
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });

      final streamedResponse = await response.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        // Si ajout (POST), récupérer la réponse XP
        if (!isFavorite) {
          final data = json.decode(utf8.decode(responseBody.codeUnits));
          final xpResponse = AddXpResponse.fromJson(data);

          return {
            'success': true,
            'message': 'Ajouté aux favoris',
            'xpResponse': xpResponse,
            'hasXp': true,
          };
        }

        return {
          'success': true,
          'message': 'Retiré des favoris',
          'hasXp': false,
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ========== PROGRESSION AVEC XP ==========

  /// 🆕 Update progress avec détection auto-complétion et XP
  Future<Map<String, dynamic>> updateProgress(
      int videoId,
      int currentTimestamp,
      bool? completed,
      ) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/$videoId/progress'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentTimestamp': currentTimestamp,
          'completed': completed,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Extraire les informations
        final videoCompleted = data['videoCompleted'] ?? false;
        final milestoneReached = data['milestoneReached'] ?? false;

        AddXpResponse? xpResponse;
        if (data['xpResponse'] != null) {
          xpResponse = AddXpResponse.fromJson(data['xpResponse']);
        }

        return {
          'success': true,
          'message': 'Progression sauvegardée',
          'videoCompleted': videoCompleted,
          'milestoneReached': milestoneReached,
          'xpResponse': xpResponse,
          'hasXp': xpResponse != null,
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ========== NOTES AVEC XP ==========

  /// 🆕 Add note avec XP
  Future<Map<String, dynamic>> addNote(
      int videoId,
      String content,
      int? timestamp,
      ) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/$videoId/notes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
          'timestamp': timestamp,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        AddXpResponse? xpResponse;
        if (data['xpResponse'] != null) {
          xpResponse = AddXpResponse.fromJson(data['xpResponse']);
        }

        return {
          'success': true,
          'message': 'Note ajoutée',
          'xpResponse': xpResponse,
          'hasXp': xpResponse != null,
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ========== MÉTHODES EXISTANTES (inchangées) ==========

  Future<Map<String, dynamic>> initializeSampleVideos() async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/init-sample'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        String message = data['message'] ?? 'Vidéos initialisées';
        return {
          'success': true,
          'message': message,
        };
      }
      return {
        'success': false,
        'message': 'Erreur ${response.statusCode}: Impossible de charger les vidéos',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e',
      };
    }
  }

  Future<Map<String, dynamic>> initializeKhanVideos() async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/init-khan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        String message = data['message'] ?? 'Vidéos Khan Academy importées';
        return {
          'success': true,
          'message': message,
        };
      }
      return {
        'success': false,
        'message': 'Erreur ${response.statusCode}: Import Khan Academy échoué',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur Khan Academy: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getVideos({
    String? query,
    String? category,
    String? difficulty,
    String sortBy = 'recent',
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await _authService.getToken();

      var url = '${ApiConfig.baseUrl}/api/videos?page=$page&size=$size&sortBy=$sortBy';
      if (query != null && query.isNotEmpty) url += '&query=$query';
      if (category != null && category.isNotEmpty) url += '&category=$category';
      if (difficulty != null && difficulty.isNotEmpty) url += '&difficulty=$difficulty';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'videos': (data['videos'] as List).map((v) => Video.fromJson(v)).toList(),
          'currentPage': data['currentPage'],
          'totalPages': data['totalPages'],
          'totalVideos': data['totalVideos'],
          'hasNext': data['hasNext'],
        };
      }
      return {'success': false, 'message': 'Erreur lors du chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getVideoById(int videoId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/$videoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {'success': true, 'video': Video.fromJson(data)};
      }
      return {'success': false, 'message': 'Vidéo non trouvée'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/my-favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // Très important
        },
      );

      print('Status: ${response.statusCode}');
      print('Content-Type: ${response.headers['content-type']}');
      print('Body length: ${response.bodyBytes.length}');

      // Vérification robuste du Content-Type
      final contentType = response.headers['content-type'];


      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes, allowMalformed: false);
        final List<dynamic> list = json.decode(decoded);

        return {
          'success': true,
          'videos': list.map((v) => Video.fromJson(v)).toList(),
        };
      }

      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e, stack) {
      print('Exception dans getFavorites: $e');
      print(stack);
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
  Future<Map<String, dynamic>> getRecentVideos() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/recent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'videos': data.map((v) => Video.fromJson(v)).toList(),
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'videos': (data['recommended'] as List)
              .map((v) => Video.fromJson(v))
              .toList(),
          'reason': data['reason'],
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getVideoNotes(int videoId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/$videoId/notes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'notes': data.map((n) => VideoNote.fromJson(n)).toList(),
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteNote(int noteId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/notes/$noteId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Note supprimée'};
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'categories': data.map((c) => c.toString()).toList()
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getVideoStats() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': json.decode(utf8.decode(response.bodyBytes))
        };
      }
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> clearAllVideos() async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/clear-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'message': data['message'] ?? 'Toutes les vidéos ont été supprimées',
        };
      }

      return {
        'success': false,
        'message': 'Erreur ${response.statusCode}: Impossible de supprimer les vidéos',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e',
      };
    }
  }
  // ========== PLAYLISTS ==========

  /// Créer une playlist
  Future<Map<String, dynamic>> createPlaylist({
    required String title,
    String? description,
    required String category,
    String? difficulty,
    bool? isPublic,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/videos/playlists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'category': category,
          'difficulty': difficulty ?? 'Moyen',
          'isPublic': isPublic ?? false,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'playlist': VideoPlaylist.fromJson(data),  // Assure-toi d'avoir le model VideoPlaylist
        };
      }
      return {'success': false, 'message': 'Erreur lors de la création'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


}