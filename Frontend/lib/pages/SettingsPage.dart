import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../providers/theme_provide.dart';
import '../providers/locale_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();

  UserSettings? _settings;
  bool _isLoading = true;

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final result = await _settingsService.getSettings();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _settings = result['settings'] as UserSettings;
        _isLoading = false;
        _parseTimeSettings();
      });
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar(result['message']);
    }
  }

  void _parseTimeSettings() {
    if (_settings!.morningTime != null) {
      final parts = _settings!.morningTime!.split(':');
      _morningTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (_settings!.afternoonTime != null) {
      final parts = _settings!.afternoonTime!.split(':');
      _afternoonTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (_settings!.eveningTime != null) {
      final parts = _settings!.eveningTime!.split(':');
      _eveningTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  // âœ… CORRECTION : Conversion camelCase â†’ snake_case pour le backend
  Future<void> _updateSetting(Map<String, dynamic> update) async {
    // Convertir les clé en snake_case
    final Map<String, dynamic> backendUpdate = {};

    update.forEach((key, value) {
      // Convertir camelCase en snake_case
      final snakeKey = _camelToSnake(key);
      backendUpdate[snakeKey] = value;
    });

    print('ðŸ”µ Envoi au backend: $backendUpdate');

    final result = await _settingsService.updateSettings(backendUpdate);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _settings = result['settings'] as UserSettings;
      });
      _showSuccessSnackBar(AppLocalizations.of(context)!.save);
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  // âœ… Convertir camelCase en snake_case
  String _camelToSnake(String camelCase) {
    return camelCase.replaceAllMapped(
        RegExp(r'[A-Z]'),
            (match) => '_${match.group(0)!.toLowerCase()}'
    );
  }

  Future<void> _pickTime(BuildContext context, String timeType) async {
    TimeOfDay currentTime;

    switch (timeType) {
      case 'morning':
        currentTime = _morningTime;
        break;
      case 'afternoon':
        currentTime = _afternoonTime;
        break;
      case 'evening':
        currentTime = _eveningTime;
        break;
      default:
        return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (pickedTime != null) {
      setState(() {
        switch (timeType) {
          case 'morning':
            _morningTime = pickedTime;
            break;
          case 'afternoon':
            _afternoonTime = pickedTime;
            break;
          case 'evening':
            _eveningTime = pickedTime;
            break;
        }
      });

      final timeString =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

      // âœ… Envoyer avec le bon nom de clé
      _updateSetting({'${timeType}Time': timeString});
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B9FD8)),
        ),
      );
    }

    if (_settings == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.cancel),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: l10n.reset,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSettings,
        color: const Color(0xFF5B9FD8),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section Confidentialité
            _buildSectionHeader(
              icon: Icons.shield_outlined,
              title: l10n.privacy,
              color: const Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.visibility_outlined,
                title: l10n.profileVisible,
                subtitle: l10n.profileVisibleDesc,
                value: _settings!.profileVisible,
                onChanged: (value) {
                  _updateSetting({'profileVisible': value});
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.psychology_outlined,
                title: l10n.shareDataAI,
                subtitle: l10n.shareDataAIDesc,
                value: _settings!.shareDataWithAI,
                onChanged: (value) {
                  _updateSetting({'shareDataWithAI': value});
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.emoji_events_outlined,
                title: l10n.showLeaderboard,
                subtitle: l10n.showLeaderboardDesc,
                value: _settings!.showInLeaderboard,
                onChanged: (value) {
                  _updateSetting({'showInLeaderboard': value});
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Section Notifications
            _buildSectionHeader(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              color: const Color(0xFFFDB33F),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: l10n.pushNotifications,
                subtitle: l10n.pushNotificationsDesc,
                value: _settings!.pushNotificationsEnabled,
                onChanged: (value) {
                  _updateSetting({'pushNotificationsEnabled': value});
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.schedule_outlined,
                title: l10n.studyReminders,
                subtitle: l10n.studyRemindersDesc,
                value: _settings!.studyRemindersEnabled,
                onChanged: (value) {
                  _updateSetting({'studyRemindersEnabled': value});
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.new_releases_outlined,
                title: l10n.newContent,
                subtitle: l10n.newContentDesc,
                value: _settings!.newContentNotifications,
                onChanged: (value) {
                  _updateSetting({'newContentNotifications': value});
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Sous-section : Horaires de notifications
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.wb_sunny_outlined,
                title: l10n.morningTime,
                trailing: Text(
                  _morningTime.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B9FD8),
                  ),
                ),
                onTap: () => _pickTime(context, 'morning'),
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.wb_cloudy_outlined,
                title: l10n.afternoonTime,
                trailing: Text(
                  _afternoonTime.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B9FD8),
                  ),
                ),
                onTap: () => _pickTime(context, 'afternoon'),
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.nightlight_outlined,
                title: l10n.eveningTime,
                trailing: Text(
                  _eveningTime.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B9FD8),
                  ),
                ),
                onTap: () => _pickTime(context, 'evening'),
              ),
            ]),

            const SizedBox(height: 16),

            // Fréquence des rappels
            _buildSettingsCard([
              _buildFrequencyTile(),
            ]),

            const SizedBox(height: 24),

            // Section Préférences
            _buildSectionHeader(
              icon: Icons.settings_outlined,
              title: l10n.preferences,
              color: const Color(0xFF00B894),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildThemeTile(context, l10n),
              const Divider(height: 1),
              _buildLanguageTile(context, l10n),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.cloud_off_outlined,
                title: l10n.offlineMode,
                subtitle: l10n.offlineModeDesc,
                value: _settings!.offlineMode,
                onChanged: (value) {
                  _updateSetting({'offlineMode': value});
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Section à propos
            _buildSectionHeader(
              icon: Icons.info_outline,
              title: l10n.about,
              color: const Color(0xFF636E72),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.info_outlined,
                title: 'Version',
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(color: Color(0xFF636E72)),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Bouton déconnexion
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // ✅ Changé
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22), // ✅ Changé
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      )
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // ✅ Changé
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22), // ✅ Changé
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary, // ✅ Changé
    );
  }

  // Remplacez la méthode _buildThemeTile dans SettingsPage.dart

  Widget _buildThemeTile(BuildContext context, AppLocalizations l10n) {
    final themeProvider = Provider.of<ThemeProvide>(context);

    final themeNames = {
      'light': l10n.themeLight,
      'dark': l10n.themeDark,
      'system': l10n.themeSystem,
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // ✅ Changé
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.brightness_6_outlined,
          color: Color(0xFF5B9FD8),
          size: 22,
        ),
      ),
      title: Text(
        l10n.theme,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        themeNames[_settings!.theme] ?? 'Système',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(l10n.theme),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(l10n.themeLight),
                  value: 'light',
                  groupValue: themeProvider.themeMode == ThemeMode.light
                      ? 'light'
                      : themeProvider.themeMode == ThemeMode.dark
                      ? 'dark'
                      : 'system',
                  onChanged: (value) async {
                    if (value == null) return;

                    // ✅ Mettre à jour le thème via le provider
                    await themeProvider.setTheme(value);

                    // ✅ Mettre à jour le backend
                    await _updateSetting({'theme': value});

                    // ✅ Fermer le dialog après la mise à jour
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.themeDark),
                  value: 'dark',
                  groupValue: themeProvider.themeMode == ThemeMode.light
                      ? 'light'
                      : themeProvider.themeMode == ThemeMode.dark
                      ? 'dark'
                      : 'system',
                  onChanged: (value) async {
                    if (value == null) return;

                    await themeProvider.setTheme(value);
                    await _updateSetting({'theme': value});

                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.themeSystem),
                  value: 'system',
                  groupValue: themeProvider.themeMode == ThemeMode.light
                      ? 'light'
                      : themeProvider.themeMode == ThemeMode.dark
                      ? 'dark'
                      : 'system',
                  onChanged: (value) async {
                    if (value == null) return;

                    await themeProvider.setTheme(value);
                    await _updateSetting({'theme': value});

                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    final languageNames = {
      'fr': l10n.languageFr,
      'en': l10n.languageEn,
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // ✅ Changé
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.language_outlined,
          color: Color(0xFF5B9FD8),
          size: 22,
        ),
      ),
      title: Text(
        l10n.language,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        languageNames[_settings!.language] ?? 'Français',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(l10n.language),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(l10n.languageFr),
                  value: 'fr',
                  groupValue: _settings!.language,
                  onChanged: (value) {
                    _updateSetting({'language': value});
                    localeProvider.setLocale(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.languageEn),
                  value: 'en',
                  groupValue: _settings!.language,
                  onChanged: (value) {
                    _updateSetting({'language': value});
                    localeProvider.setLocale(value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildFrequencyTile() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.notifications_active_outlined,
          color: Color(0xFFFDB33F), // Orange vif – parfait pour les rappels
          size: 24,
        ),
      ),
      title: Text(
        l10n.reminderFrequencyTitle,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        l10n.reminderFrequencySubtitle(_settings!.reminderFrequency),
        style: TextStyle(
          fontSize: 13.5,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.5)),
      onTap: () => _showFrequencyDialog(l10n, colorScheme),
    );
  }

  void _showFrequencyDialog(AppLocalizations l10n, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(Icons.repeat_rounded, size: 32, color: colorScheme.primary),
          title: Text(
            l10n.reminderFrequencyTitle,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [1, 2, 3].map((freq) {
      return RadioListTile<int>(
      activeColor: colorScheme.primary,
      title: Text(
      l10n.timesPerDay(freq),
      style: const TextStyle(fontSize: 16),
      ),
      subtitle: freq == 1
      ? Text(l10n.onceADay, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)))
          : null,
      value: freq,
      groupValue: _settings!.reminderFrequency,
      onChanged: (value) {
      if (value != null) {
      _updateSetting({'reminderFrequency': value});
      Navigator.pop(context);
      }
      },
      );
      }).toList(),
    ),
    actions: [
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text(l10n.cancel, style: TextStyle(color: colorScheme.primary)),
    ),
    ],
    ),
    );
  }
}