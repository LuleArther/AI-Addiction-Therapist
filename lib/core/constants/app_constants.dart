// App Constants
class AppConstants {
  // App Info
  static const String appName = 'AI Therapist';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String progressCollection = 'progress';
  static const String sessionsCollection = 'sessions';
  static const String achievementsCollection = 'achievements';
  static const String communityCollection = 'community';
  
  // Note: API keys are loaded from environment variables
  // See lib/core/config/env_config.dart
  // Supabase configuration is handled in main.dart
  
  // Storage Keys
  static const String userIdKey = 'userId';
  static const String onboardingCompleteKey = 'onboardingComplete';
  static const String selectedAddictionKey = 'selectedAddiction';
  static const String streakCountKey = 'streakCount';
  static const String lastCheckInKey = 'lastCheckIn';
  
  // Addiction Types
  static const List<String> addictionTypes = [
    'Smoking',
    'Alcohol',
    'Gambling',
    'Pornography',
    'Drugs',
    'Gaming',
    'Social Media',
    'Shopping',
    'Food',
    'Other',
  ];
  
  // Achievement Milestones
  static const List<int> milestones = [1, 7, 14, 30, 60, 90, 180, 365];
  
  // Animations
  static const String congratsAnimation = 'assets/animations/congratulations.json';
  static const String meditationAnimation = 'assets/animations/meditation.json';
  static const String breathingAnimation = 'assets/animations/breathing.json';
}
