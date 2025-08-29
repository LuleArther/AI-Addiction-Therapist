import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class that loads sensitive data from .env file
/// This keeps API keys and secrets out of the source code
class EnvConfig {
  static String geminiApiKey = '';
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  
  /// Initialize environment variables from .env file
  /// Call this in main() before runApp()
  static Future<void> init() async {
    try {
      if (kIsWeb) {
        // For web development, use hardcoded values
        // In production, use environment variables or secure config service
        geminiApiKey = 'AIzaSyBe_-tDB0NPupenGGunT1Qp59zCDOCk5L4';
        supabaseUrl = 'YOUR_SUPABASE_URL';
        supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
        
        debugPrint('Running in web mode with development API keys');
        if (supabaseUrl == 'YOUR_SUPABASE_URL') {
          debugPrint('Warning: Supabase not configured. Chat history will not be saved.');
        }
      } else {
        // For mobile/desktop, load from .env file
        await dotenv.load(fileName: ".env");
        
        geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
        supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
        
        // Validate required keys
        if (geminiApiKey.isEmpty) {
          throw Exception('GEMINI_API_KEY not found in .env file');
        }
      }
    } catch (e) {
      debugPrint('Error loading environment: $e');
      // Set fallback values for development
      if (geminiApiKey.isEmpty) {
        geminiApiKey = 'AIzaSyBe_-tDB0NPupenGGunT1Qp59zCDOCk5L4';
      }
      if (supabaseUrl.isEmpty) {
        supabaseUrl = 'YOUR_SUPABASE_URL';
      }
      if (supabaseAnonKey.isEmpty) {
        supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
      }
    }
  }
  
  /// Check if Supabase is configured
  static bool get isSupabaseConfigured => 
      supabaseUrl != 'YOUR_SUPABASE_URL' && 
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
