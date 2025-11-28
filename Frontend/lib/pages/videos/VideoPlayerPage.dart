import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/video.dart';
import '../../models/video_note.dart';
import '../../models/add_xp_response.dart';
import '../../services/video_service.dart';
import 'dart:async';


class VideoPlayerPage extends StatefulWidget {
  final Video video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with TickerProviderStateMixin {
  final _videoService = VideoService();
  late YoutubePlayerController _controller;
  late TabController _tabController;
  Timer? _progressTimer;

  List<VideoNote> _notes = [];
  bool _isLoadingNotes = false;
  final _noteController = TextEditingController();
  bool _isFavorite = false;
  bool _hasShownCompletionDialog = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.video.isFavorite;
    _tabController = TabController(length: 3, vsync: this);

    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        startAt: widget.video.lastTimestamp,
      ),
    );

    _controller.addListener(_onPlayerStateChange);
    _startProgressTracking();
    _loadNotes();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller.dispose();
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onPlayerStateChange() {
    if (_controller.value.isPlaying) {
      _startProgressTracking();
    }
  }

  // 🆕 SUIVI DE PROGRESSION AVEC DÉTECTION AUTO-COMPLÉTION
  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_controller.value.isPlaying) {
        final position = _controller.value.position.inSeconds;
        final duration = _controller.value.metaData.duration.inSeconds;

        // Calculer le pourcentage
        final percentage = duration > 0 ? (position / duration * 100) : 0.0;

        // 🎯 COMPLÉTION AUTOMATIQUE À 90%
        final shouldAutoComplete = percentage >= 90.0 && !_hasShownCompletionDialog;

        final result = await _videoService.updateProgress(
          widget.video.id,
          position,
          shouldAutoComplete ? true : null,
        );

        // 🎉 AFFICHER DIALOG SI VIDÉO COMPLÉTÉE
        if (result['hasXp'] == true && shouldAutoComplete && mounted) {
          _hasShownCompletionDialog = true;
          final xpResponse = result['xpResponse'] as AddXpResponse;
          final milestoneReached = result['milestoneReached'] ?? false;
          _showCompletionDialog(xpResponse, milestoneReached);
        }
      }
    });
  }

  // 🎉 DIALOG DE FÉLICITATIONS + XP
  void _showCompletionDialog(AddXpResponse xpResponse, bool milestoneReached) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône succès
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              milestoneReached ? '🎯 MILESTONE ATTEINT !' : '🎉 Vidéo Complétée !',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message XP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '+${xpResponse.xpAdded} XP',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    xpResponse.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progression niveau
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveau ${xpResponse.currentLevel}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${xpResponse.xpProgressInCurrentLevel}/${xpResponse.xpForNextLevel} XP',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: xpResponse.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C5CE7)),
                  minHeight: 8,
                ),
              ],
            ),

            // 🎊 LEVEL UP
            if (xpResponse.leveledUp) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'NIVEAU ${xpResponse.newLevel} !',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoadingNotes = true);
    final result = await _videoService.getVideoNotes(widget.video.id);
    if (result['success'] && mounted) {
      setState(() {
        _notes = result['notes'];
        _isLoadingNotes = false;
      });
    }
  }

  // 🆕 AJOUT NOTE AVEC XP
  Future<void> _addNote() async {
    if (_noteController.text.isEmpty) return;

    final currentTime = _controller.value.position.inSeconds;
    final result = await _videoService.addNote(
      widget.video.id,
      _noteController.text,
      currentTime,
    );

    if (result['success']) {
      _noteController.clear();
      _loadNotes();

      // 🎯 AFFICHER XP GAGNÉ
      if (result['hasXp'] == true && mounted) {
        final xpResponse = result['xpResponse'] as AddXpResponse;
        _showXpSnackBar(xpResponse);
      }
    }
  }

  // 🆕 TOGGLE FAVORITE AVEC XP
  Future<void> _toggleFavorite() async {
    final result = await _videoService.toggleFavorite(widget.video.id, _isFavorite);

    if (result['success'] && mounted) {
      setState(() => _isFavorite = !_isFavorite);

      // 🎯 AFFICHER XP SI AJOUT
      if (result['hasXp'] == true) {
        final xpResponse = result['xpResponse'] as AddXpResponse;
        _showXpSnackBar(xpResponse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  // 🎯 SNACKBAR XP ÉLÉGANTE
  void _showXpSnackBar(AddXpResponse xpResponse) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${xpResponse.xpAdded} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    xpResponse.message,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _deleteNote(int noteId) async {
    final result = await _videoService.deleteNote(noteId);
    if (result['success']) {
      _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note supprimée')),
        );
      }
    }
  }

  void _jumpToTimestamp(int seconds) {
    _controller.seekTo(Duration(seconds: seconds));
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF6C5CE7),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF6C5CE7),
          handleColor: Color(0xFF6C5CE7),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                player,
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        // En-tête vidéo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.video.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // CŒUR (favori)
                                  IconButton(
                                    icon: Icon(
                                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: _isFavorite ? Colors.red : Colors.grey.shade600,
                                    ),
                                    onPressed: _toggleFavorite,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.video.channelTitle,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.remove_red_eye,
                                    '${widget.video.viewCount} vues',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildInfoChip(
                                    Icons.access_time,
                                    widget.video.formattedDuration,
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(widget.video.difficulty)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.video.difficulty,
                                      style: TextStyle(
                                        color: _getDifficultyColor(widget.video.difficulty),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Onglets
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF6C5CE7),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF6C5CE7),
                            tabs: const [
                              Tab(text: 'Description'),
                              Tab(text: 'Notes'),
                              Tab(text: 'Similaires'),
                            ],
                          ),
                        ),

                        // Contenu
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDescriptionTab(),
                              _buildNotesTab(),
                              _buildRelatedVideosTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.video.description.isNotEmpty
                ? widget.video.description
                : 'Aucune description disponible.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          const Text(
            'Catégorie',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(widget.video.category)),
              ...widget.video.tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.grey.shade200,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        // Zone ajout note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Ajouter une note... (+10 XP)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 32),
                color: const Color(0xFF6C5CE7),
                onPressed: _addNote,
              ),
            ],
          ),
        ),

        // Liste des notes
        Expanded(
          child: _isLoadingNotes
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune note',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: note.timestamp != null
                      ? InkWell(
                    onTap: () => _jumpToTimestamp(note.timestamp!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        note.formattedTimestamp ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                      : null,
                  title: Text(note.content),
                  subtitle: Text(
                    'Ajoutée le ${_formatDate(note.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(note.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedVideosTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Vidéos similaires',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'À venir prochainement',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}