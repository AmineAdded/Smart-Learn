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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
  /// In en, this message translates to:
  /// **'SmartLearn'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @profileVisible.
  ///
  /// In en, this message translates to:
  /// **'Profile visible'**
  String get profileVisible;

  /// No description provided for @profileVisibleDesc.
  ///
  /// In en, this message translates to:
  /// **'Make my profile visible to others'**
  String get profileVisibleDesc;

  /// No description provided for @shareDataAI.
  ///
  /// In en, this message translates to:
  /// **'AI Data Sharing'**
  String get shareDataAI;

  /// No description provided for @shareDataAIDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve recommendations'**
  String get shareDataAIDesc;

  /// No description provided for @showLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get showLeaderboard;

  /// No description provided for @showLeaderboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Appear in leaderboards'**
  String get showLeaderboardDesc;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts'**
  String get pushNotificationsDesc;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study reminders'**
  String get studyReminders;

  /// No description provided for @studyRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily notifications'**
  String get studyRemindersDesc;

  /// No description provided for @newContent.
  ///
  /// In en, this message translates to:
  /// **'New content'**
  String get newContent;

  /// No description provided for @newContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Quizzes and videos'**
  String get newContentDesc;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Interface theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'☀️ Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'🌙 Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'⚙️ System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageFr.
  ///
  /// In en, this message translates to:
  /// **'🇫🇷 Français'**
  String get languageFr;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'🇬🇧 English'**
  String get languageEn;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @offlineModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Download content'**
  String get offlineModeDesc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @notificationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Notification schedule'**
  String get notificationSchedule;

  /// No description provided for @notificationScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose times'**
  String get notificationScheduleDesc;

  /// No description provided for @notificationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Reminder frequency'**
  String get notificationFrequency;

  /// No description provided for @notificationFrequencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Number per day'**
  String get notificationFrequencyDesc;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification every day'**
  String get dailyReminderDesc;

  /// No description provided for @morningTime.
  ///
  /// In en, this message translates to:
  /// **'Morning time'**
  String get morningTime;

  /// No description provided for @afternoonTime.
  ///
  /// In en, this message translates to:
  /// **'Afternoon time'**
  String get afternoonTime;

  /// No description provided for @eveningTime.
  ///
  /// In en, this message translates to:
  /// **'Evening time'**
  String get eveningTime;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @secureAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureAccount;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @recommendedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Recommended Quizzes'**
  String get recommendedQuizzes;

  /// No description provided for @recentVideos.
  ///
  /// In en, this message translates to:
  /// **'Recent Videos'**
  String get recentVideos;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @isNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get isNew;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @totalXP.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXP;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Completed'**
  String get quizCompleted;

  /// No description provided for @studyTime.
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get studyTime;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @videosWatched.
  ///
  /// In en, this message translates to:
  /// **'Videos Watched'**
  String get videosWatched;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @globalRank.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get globalRank;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Success message after login
  ///
  /// In en, this message translates to:
  /// **'Login successful! Welcome {name}'**
  String loginSuccess(Object name);

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Google login under development'**
  String get featureInDevelopment;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @oldPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get oldPasswordRequired;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureYourAccount;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @progressToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Progress to level'**
  String get progressToNextLevel;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalXPLabel.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXPLabel;

  /// No description provided for @quizzesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Completed'**
  String get quizzesCompleted;

  /// No description provided for @successRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRateLabel;

  /// No description provided for @studyTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get studyTimeLabel;

  /// No description provided for @consecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Days'**
  String get consecutiveDays;

  /// No description provided for @videosWatchedLabel.
  ///
  /// In en, this message translates to:
  /// **'Videos Watched'**
  String get videosWatchedLabel;

  /// No description provided for @weeklyProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressLabel;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @goalsAndRanking.
  ///
  /// In en, this message translates to:
  /// **'Goals & Ranking'**
  String get goalsAndRanking;

  /// No description provided for @globalRankLabel.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get globalRankLabel;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// No description provided for @loadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStats;

  /// No description provided for @collegeLevel.
  ///
  /// In en, this message translates to:
  /// **'Middle School'**
  String get collegeLevel;

  /// No description provided for @highSchoolLevel.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get highSchoolLevel;

  /// No description provided for @universityLevel.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get universityLevel;

  /// No description provided for @continuingEducation.
  ///
  /// In en, this message translates to:
  /// **'Continuing Education'**
  String get continuingEducation;

  /// No description provided for @selfTaught.
  ///
  /// In en, this message translates to:
  /// **'Self-taught'**
  String get selfTaught;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education level'**
  String get educationLevel;

  /// No description provided for @manageInterests.
  ///
  /// In en, this message translates to:
  /// **'Manage my interests'**
  String get manageInterests;

  /// No description provided for @chooseYourTopics.
  ///
  /// In en, this message translates to:
  /// **'Choose the topics that interest you.'**
  String get chooseYourTopics;

  /// Title when it's during onboarding
  ///
  /// In en, this message translates to:
  /// **'Choose your interests'**
  String get chooseYourInterests;

  /// Title when editing interests
  ///
  /// In en, this message translates to:
  /// **'Edit my interests'**
  String get editInterests;

  /// No description provided for @selectSubjectsYouLike.
  ///
  /// In en, this message translates to:
  /// **'Select the subjects that interest you'**
  String get selectSubjectsYouLike;

  /// No description provided for @updateYourInterests.
  ///
  /// In en, this message translates to:
  /// **'Update your areas of interest'**
  String get updateYourInterests;

  /// Dynamic counter of selected categories
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No selection} =1{1 selected} other{{count} selected}}'**
  String selectedCount(num count);

  /// No description provided for @selectAtLeastOneInterest.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one area of interest'**
  String get selectAtLeastOneInterest;

  /// No description provided for @interestsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Interests saved successfully!'**
  String get interestsSavedSuccess;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// Final button text during onboarding
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// Button text when editing interests
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmNewPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordHintMin8.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get passwordHintMin8;

  /// No description provided for @passwordMin8Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8Chars;

  /// No description provided for @passwordUppercaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordUppercaseRequired;

  /// No description provided for @passwordDigitRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a digit'**
  String get passwordDigitRequired;

  /// No description provided for @passwordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Must be different from old password'**
  String get passwordMustBeDifferent;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain:'**
  String get passwordRequirements;

  /// No description provided for @reminderFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder frequency'**
  String get reminderFrequencyTitle;

  /// Subtitle text in the settings tile
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{time per day} other{{count} times per day}}'**
  String reminderFrequencySubtitle(num count);

  /// Used in the frequency selection dialog
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time per day} other{{count} times per day}}'**
  String timesPerDay(num count);

  /// No description provided for @onceADay.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get onceADay;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @beginnerLevel.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginnerLevel;

  /// No description provided for @quizzesInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Quizzes section under development'**
  String get quizzesInDevelopment;

  /// No description provided for @videosInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Videos section under development'**
  String get videosInDevelopment;

  /// No description provided for @notificationsInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Notifications page under development'**
  String get notificationsInDevelopment;

  /// No description provided for @aiLevelMessage.
  ///
  /// In en, this message translates to:
  /// **'Your level has been assessed as: {level}'**
  String aiLevelMessage(Object level);

  /// No description provided for @continueWithRecommendedQuiz.
  ///
  /// In en, this message translates to:
  /// **'Continue with the recommended Math quiz!'**
  String get continueWithRecommendedQuiz;

  /// No description provided for @advancedAlgebra.
  ///
  /// In en, this message translates to:
  /// **'Advanced Algebra'**
  String get advancedAlgebra;

  /// No description provided for @physicsMechanics.
  ///
  /// In en, this message translates to:
  /// **'Physics: Mechanics'**
  String get physicsMechanics;

  /// No description provided for @mathFunctions.
  ///
  /// In en, this message translates to:
  /// **'Mathematical Functions'**
  String get mathFunctions;

  /// No description provided for @chemistryIntro.
  ///
  /// In en, this message translates to:
  /// **'Introduction to Chemistry'**
  String get chemistryIntro;

  /// No description provided for @modernHistory.
  ///
  /// In en, this message translates to:
  /// **'Modern History'**
  String get modernHistory;

  /// No description provided for @openingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Opening quiz: {title}'**
  String openingQuiz(Object title);

  /// No description provided for @playingVideo.
  ///
  /// In en, this message translates to:
  /// **'Playing: {title}'**
  String playingVideo(Object title);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinue;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountYet;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailExample;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short (min. 6 characters)'**
  String get passwordTooShort;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a verification code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome {name}'**
  String signUpSuccess(Object name);

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms of use'**
  String get acceptTermsRequired;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @signUpError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get signUpError;

  /// No description provided for @googleSignUpInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Google signup under development'**
  String get googleSignUpInDevelopment;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @joinSmartLearn.
  ///
  /// In en, this message translates to:
  /// **'Join SmartLearn and start learning'**
  String get joinSmartLearn;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andThe.
  ///
  /// In en, this message translates to:
  /// **'and the'**
  String get andThe;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @yourLastName.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get yourLastName;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get lastNameRequired;

  /// No description provided for @yourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get yourFirstName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequired;

  /// No description provided for @selectYourLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your level'**
  String get selectYourLevel;

  /// No description provided for @educationLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your education level'**
  String get educationLevelRequired;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get passwordHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
