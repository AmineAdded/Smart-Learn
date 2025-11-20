import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'SmartLearn'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get hello;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @privacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @profileVisible.
  ///
  /// In fr, this message translates to:
  /// **'Profil visible'**
  String get profileVisible;

  /// No description provided for @profileVisibleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rendre mon profil visible aux autres'**
  String get profileVisibleDesc;

  /// No description provided for @shareDataAI.
  ///
  /// In fr, this message translates to:
  /// **'Partage de données IA'**
  String get shareDataAI;

  /// No description provided for @shareDataAIDesc.
  ///
  /// In fr, this message translates to:
  /// **'Améliorer les recommandations'**
  String get shareDataAIDesc;

  /// No description provided for @showLeaderboard.
  ///
  /// In fr, this message translates to:
  /// **'Classements'**
  String get showLeaderboard;

  /// No description provided for @showLeaderboardDesc.
  ///
  /// In fr, this message translates to:
  /// **'Apparaître dans les classements'**
  String get showLeaderboardDesc;

  /// No description provided for @pushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des alertes'**
  String get pushNotificationsDesc;

  /// No description provided for @studyReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels d\'étude'**
  String get studyReminders;

  /// No description provided for @studyRemindersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Notifications quotidiennes'**
  String get studyRemindersDesc;

  /// No description provided for @newContent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux contenus'**
  String get newContent;

  /// No description provided for @newContentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Quiz et vidéos'**
  String get newContentDesc;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème de l\'interface'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'☀️ Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'🌙 Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'⚙️ Système'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageFr.
  ///
  /// In fr, this message translates to:
  /// **'🇫🇷 Français'**
  String get languageFr;

  /// No description provided for @languageEn.
  ///
  /// In fr, this message translates to:
  /// **'🇬🇧 English'**
  String get languageEn;

  /// No description provided for @languageAr.
  ///
  /// In fr, this message translates to:
  /// **'🇸🇦 العربية'**
  String get languageAr;

  /// No description provided for @offlineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get offlineMode;

  /// No description provided for @offlineModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les contenus'**
  String get offlineModeDesc;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @notificationSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaires de notifications'**
  String get notificationSchedule;

  /// No description provided for @notificationScheduleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les heures'**
  String get notificationScheduleDesc;

  /// No description provided for @notificationFrequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence des rappels'**
  String get notificationFrequency;

  /// No description provided for @notificationFrequencyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Nombre par jour'**
  String get notificationFrequencyDesc;

  /// No description provided for @dailyReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Notification chaque jour'**
  String get dailyReminderDesc;

  /// No description provided for @morningTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure du matin'**
  String get morningTime;

  /// No description provided for @afternoonTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de l\'après-midi'**
  String get afternoonTime;

  /// No description provided for @eveningTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure du soir'**
  String get eveningTime;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get myProfile;

  /// No description provided for @myProgress.
  ///
  /// In fr, this message translates to:
  /// **'Ma Progression'**
  String get myProgress;

  /// No description provided for @personalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInformation;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @secureAccount.
  ///
  /// In fr, this message translates to:
  /// **'Sécurisez votre compte'**
  String get secureAccount;

  /// No description provided for @accountInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get accountInfo;

  /// No description provided for @role.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get role;

  /// No description provided for @memberSince.
  ///
  /// In fr, this message translates to:
  /// **'Membre depuis'**
  String get memberSince;

  /// No description provided for @recommendedQuizzes.
  ///
  /// In fr, this message translates to:
  /// **'Quiz recommandés'**
  String get recommendedQuizzes;

  /// No description provided for @recentVideos.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos récentes'**
  String get recentVideos;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @questions.
  ///
  /// In fr, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @difficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get hard;

  /// No description provided for @duration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get duration;

  /// No description provided for @isNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get isNew;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @quizzes.
  ///
  /// In fr, this message translates to:
  /// **'Quiz'**
  String get quizzes;

  /// No description provided for @videos.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos'**
  String get videos;

  /// No description provided for @progress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get progress;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @level.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get level;

  /// No description provided for @totalXP.
  ///
  /// In fr, this message translates to:
  /// **'XP Total'**
  String get totalXP;

  /// No description provided for @quizCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Quiz Complétés'**
  String get quizCompleted;

  /// No description provided for @studyTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps d\'étude'**
  String get studyTime;

  /// No description provided for @successRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de réussite'**
  String get successRate;

  /// No description provided for @currentStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série actuelle'**
  String get currentStreak;

  /// No description provided for @videosWatched.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos regardées'**
  String get videosWatched;

  /// No description provided for @weeklyProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression hebdomadaire'**
  String get weeklyProgress;

  /// No description provided for @achievements.
  ///
  /// In fr, this message translates to:
  /// **'Réalisations'**
  String get achievements;

  /// No description provided for @globalRank.
  ///
  /// In fr, this message translates to:
  /// **'Classement global'**
  String get globalRank;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue ! Connectez-vous pour continuer'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @orContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continueWithApple;

  /// No description provided for @dontHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie !'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get loginError;

  /// No description provided for @unexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite'**
  String get unexpectedError;

  /// No description provided for @featureInDevelopment.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité en cours de développement'**
  String get featureInDevelopment;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'L\'email est requis'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @oldPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est requis'**
  String get oldPasswordRequired;

  /// No description provided for @myProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get myProfileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfo;

  /// No description provided for @editButton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePasswordTitle;

  /// No description provided for @secureYourAccount.
  ///
  /// In fr, this message translates to:
  /// **'Sécurisez votre compte'**
  String get secureYourAccount;

  /// No description provided for @accountInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get accountInformation;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le profil'**
  String get unableToLoadProfile;

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryButton;

  /// No description provided for @currentLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau actuel'**
  String get currentLevel;

  /// No description provided for @progressToNextLevel.
  ///
  /// In fr, this message translates to:
  /// **'Progression vers niveau'**
  String get progressToNextLevel;

  /// No description provided for @statistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistics;

  /// No description provided for @totalXPLabel.
  ///
  /// In fr, this message translates to:
  /// **'XP Total'**
  String get totalXPLabel;

  /// No description provided for @quizzesCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Quiz Complétés'**
  String get quizzesCompleted;

  /// No description provided for @successRateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taux de réussite'**
  String get successRateLabel;

  /// No description provided for @studyTimeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Temps d\'étude'**
  String get studyTimeLabel;

  /// No description provided for @consecutiveDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours consécutifs'**
  String get consecutiveDays;

  /// No description provided for @videosWatchedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos vues'**
  String get videosWatchedLabel;

  /// No description provided for @weeklyProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Progression hebdomadaire'**
  String get weeklyProgressLabel;

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine passée'**
  String get lastWeek;

  /// No description provided for @goalsAndRanking.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs et Classement'**
  String get goalsAndRanking;

  /// No description provided for @globalRankLabel.
  ///
  /// In fr, this message translates to:
  /// **'Classement global'**
  String get globalRankLabel;

  /// No description provided for @outOf.
  ///
  /// In fr, this message translates to:
  /// **'sur'**
  String get outOf;

  /// No description provided for @loadingStats.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des statistiques...'**
  String get loadingStats;

  /// No description provided for @collegeLevel.
  ///
  /// In fr, this message translates to:
  /// **'Collège'**
  String get collegeLevel;

  /// No description provided for @highSchoolLevel.
  ///
  /// In fr, this message translates to:
  /// **'Lycée'**
  String get highSchoolLevel;

  /// No description provided for @universityLevel.
  ///
  /// In fr, this message translates to:
  /// **'Université'**
  String get universityLevel;

  /// No description provided for @continuingEducation.
  ///
  /// In fr, this message translates to:
  /// **'Formation continue'**
  String get continuingEducation;

  /// No description provided for @selfTaught.
  ///
  /// In fr, this message translates to:
  /// **'Autodidacte'**
  String get selfTaught;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès'**
  String get profileUpdatedSuccess;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès'**
  String get passwordChangedSuccess;

  /// No description provided for @errorLoadingData.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des données'**
  String get errorLoadingData;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @educationLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'études'**
  String get educationLevel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
