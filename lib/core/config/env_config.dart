import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class that loads sensitive data from .env file
/// This keeps API keys and secrets out of the source code
class EnvConfig {
  static late String geminiApiKey;
  static late String supabaseUrl;
  static late String supabaseAnonKey;
  
  /// Initialize environment variables from .env file
  /// Call this in main() before runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
    
    geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
    
    // Validate required keys
    if (geminiApiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
  }
  
  /// Check if Supabase is configured
  static bool get isSupabaseConfigured => 
      supabaseUrl != 'YOUR_SUPABASE_URL' && 
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
