import 'package:flutter/material.dart';
import '../../services/video_service.dart';
import '../../models/video.dart';
import '../../models/add_xp_response.dart';
import 'VideoPlayerPage.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage>
    with SingleTickerProviderStateMixin {
  final _videoService = VideoService();
  final _searchController = TextEditingController();

  List<Video> _videos = [];
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isInitializing = false;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String _sortBy = 'recent';
  int _currentPage = 0;
  bool _hasMore = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _handleTabChange(_tabController.index);
      }
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCategories();
    await _loadVideos();
  }

  Future<void> _loadCategories() async {
    final result = await _videoService.getCategories();
    if (result['success'] && mounted) {
      setState(() {
        _categories = result['categories'];
      });
    }
  }

  Future<void> _loadVideos({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _videos.clear();
        _isLoading = true;
      });
    }

    final result = await _videoService.getVideos(
      query: _searchController.text.isNotEmpty ? _searchController.text : null,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      sortBy: _sortBy,
      page: _currentPage,
      size: 20,
    );

    if (result['success'] && mounted) {
      setState(() {
        if (refresh) {
          _videos = result['videos'];
        } else {
          _videos.addAll(result['videos']);
        }
        _hasMore = result['hasNext'];
        _isLoading = false;
      });
    }
  }

  // ✅ CORRECTION : Charger les favoris dans l'onglet au lieu de rediriger
  Future<void> _handleTabChange(int index) async {
    setState(() {
      _isLoading = true;
      _videos.clear();
      _currentPage = 0;
    });

    switch (index) {
      case 0: // Toutes
        _selectedCategory = null;
        await _loadVideos(refresh: true);
        break;

      case 1: // Recommandations
        final result = await _videoService.getRecommendations();
        if (result['success'] && mounted) {
          setState(() {
            _videos = result['videos'];
            _isLoading = false;
          });
        }
        return;

      case 2: // Récentes
        final result = await _videoService.getRecentVideos();
        if (result['success'] && mounted) {
          setState(() {
            _videos = result['videos'];
            _isLoading = false;
          });
        }
        return;

      case 3: // ✅ FAVORIS : Charger dans l'onglet
        final result = await _videoService.getFavorites();
        if (result['success'] && mounted) {
          setState(() {
            _videos = result['videos'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _videos = [];
            _isLoading = false;
          });
        }
        return;
    }
  }

  Future<void> _initializeVideos() async {
    setState(() => _isInitializing = true);

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialiser les vidéos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ Cela supprimera toutes les vidéos existantes.'),
            const SizedBox(height: 16),
            const Text('Choisissez la source :'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'sample'),
            child: const Text('Vidéos d\'exemple (8 vidéos)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'khan'),
            child: const Text('Khan Academy (100 vidéos)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (choice == null) {
      setState(() => _isInitializing = false);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Nettoyage et import en cours...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF6C5CE7),
        ),
      );
    }

    final clearResult = await _videoService.clearAllVideos();

    if (!clearResult['success']) {
      setState(() => _isInitializing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de nettoyage: ${clearResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final result = choice == 'khan'
        ? await _videoService.initializeKhanVideos()
        : await _videoService.initializeSampleVideos();

    setState(() => _isInitializing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Opération terminée'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      if (result['success']) {
        await Future.delayed(const Duration(milliseconds: 500));
        _loadVideos(refresh: true);
      }
    }
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border:
                  Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtres',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedCategory = null;
                          _selectedDifficulty = null;
                          _sortBy = 'recent';
                        });
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catégorie',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedCategory = selected ? cat : null;
                              });
                            },
                          );
                        }).toList(),
                      ),



                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                      _loadVideos(refresh: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Appliquer les filtres',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bibliothèque Vidéo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une vidéo...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadVideos(refresh: true);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: _showFiltersSheet,
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _loadVideos(refresh: true),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF6C5CE7),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF6C5CE7),
                tabs: const [
                  Tab(text: 'Toutes'),
                  Tab(text: 'Pour vous'),
                  Tab(text: 'Récentes'),
                  Tab(text: 'Favoris'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () => _handleTabChange(_tabController.index),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _videos.length + (_hasMore && _tabController.index == 0 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _videos.length) {
              _currentPage++;
              _loadVideos();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildVideoCard(_videos[index], index);
          },
        ),
      ),
      floatingActionButton: _videos.isEmpty && !_isLoading
          ? FloatingActionButton.extended(
        onPressed: _isInitializing ? null : _initializeVideos,
        icon: _isInitializing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : const Icon(Icons.download),
        label:
        Text(_isInitializing ? 'Chargement...' : 'Charger vidéos'),
        backgroundColor: const Color(0xFF6C5CE7),
      )
          : null,
    );
  }

  Widget _buildEmptyState() {
    // ✅ Message différent pour l'onglet Favoris
    if (_tabController.index == 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune vidéo favorite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des vidéos à vos favoris\npour les retrouver facilement',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune vidéo trouvée',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton ci-dessous\npour charger des vidéos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Video video, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(video: video),
            ),
          ).then((_) => _handleTabChange(_tabController.index));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.video_library, size: 64),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.formattedDuration,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                if (video.isWatched)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: video.progressPercentage / 100,
                      backgroundColor: Colors.transparent,
                      valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF6C5CE7)),
                      minHeight: 4,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✅ CORRECTION TOGGLE FAVORITE
                      IconButton(
                        icon: Icon(
                          video.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: video.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () async {
                          final oldStatus = video.isFavorite;
                          final newStatus = !oldStatus;

                          setState(() {
                            _videos[index] = video.copyWith(isFavorite: newStatus);
                          });

                          final result = await _videoService.toggleFavorite(
                              video.id, oldStatus);

                          if (result['success']) {
                            if (newStatus && result['hasXp'] == true && mounted) {
                              final xpResponse = result['xpResponse'] as AddXpResponse;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '+${xpResponse.xpAdded} XP',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Text(
                                              'Ajouté aux favoris',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF6C5CE7),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              _videos[index] = video.copyWith(isFavorite: oldStatus);
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? 'Erreur'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.channelTitle,
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(video.category, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(video.difficulty,
                          _getDifficultyColor(video.difficulty)),
                      const Spacer(),
                      Text(
                        '${video.viewCount} vues',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return Colors.green;
      case 'Moyen':
        return Colors.orange;
      case 'Difficile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}