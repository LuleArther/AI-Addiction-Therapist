import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';

class AIService {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  
  AIService() {
    _initializeModel();
  }
  
  void _initializeModel() {
    // Use API key from environment configuration
    final apiKey = EnvConfig.geminiApiKey;
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
      systemInstruction: Content.text(
        '''You are a compassionate and professional AI therapist specializing in addiction recovery. 
        Your role is to:
        1. Provide empathetic, non-judgmental support
        2. Offer evidence-based coping strategies
        3. Help users identify triggers and develop healthy habits
        4. Celebrate progress and provide encouragement
        5. Suggest practical exercises and techniques
        6. Never provide medical advice or suggest stopping medication
        7. Encourage professional help when appropriate
        8. Maintain strict confidentiality and create a safe space
        
        Remember to be warm, understanding, and supportive in all interactions.
        Use motivational interviewing techniques and cognitive-behavioral approaches.
        Always prioritize the user's safety and well-being.'''
      ),
    );
    
    _chatSession = _model.startChat(history: []);
  }
  
  Future<String> sendMessage(String message, String addictionType) async {
    try {
      // Add context about the user's addiction type
      final contextualMessage = 'User struggling with $addictionType addiction: $message';
      
      final response = await _chatSession.sendMessage(
        Content.text(contextualMessage),
      );
      
      return response.text ?? 'I understand you\'re going through a difficult time. Let\'s work through this together.';
    } catch (e) {
      print('Error sending message to AI: $e');
      return _getOfflineResponse(message);
    }
  }
  
  Future<String> generateMotivationalQuote(String addictionType) async {
    try {
      final prompt = '''Generate a short, powerful motivational quote for someone recovering from $addictionType addiction. 
      Make it personal, encouraging, and focused on strength and progress. 
      Keep it under 30 words.''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? _getDefaultMotivationalQuote();
    } catch (e) {
      print('Error generating motivational quote: $e');
      return _getDefaultMotivationalQuote();
    }
  }
  
  Future<String> generateDailyTip(String addictionType, int streakDays) async {
    try {
      final prompt = '''Generate a practical daily tip for someone on day $streakDays of recovery from $addictionType addiction. 
      Make it actionable and specific. 
      Keep it under 50 words.''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? _getDefaultDailyTip();
    } catch (e) {
      print('Error generating daily tip: $e');
      return _getDefaultDailyTip();
    }
  }
  
  Future<String> handleRelapse(String addictionType) async {
    try {
      final prompt = '''Provide compassionate support for someone who has relapsed in their $addictionType recovery. 
      Focus on:
      1. Removing guilt and shame
      2. Viewing it as a learning opportunity
      3. Immediate coping strategies
      4. Getting back on track
      Keep response under 100 words.''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? _getDefaultRelapseSupport();
    } catch (e) {
      print('Error handling relapse: $e');
      return _getDefaultRelapseSupport();
    }
  }
  
  Future<List<String>> generateCopingStrategies(String addictionType, String trigger) async {
    try {
      final prompt = '''Generate 5 specific coping strategies for someone with $addictionType addiction facing this trigger: $trigger.
      Format as a simple list, each strategy should be one sentence.''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      final text = response.text ?? '';
      return text.split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.replaceAll(RegExp(r'^\d+\.?\s*|-\s*'), ''))
          .take(5)
          .toList();
    } catch (e) {
      print('Error generating coping strategies: $e');
      return _getDefaultCopingStrategies();
    }
  }
  
  void resetChat() {
    _chatSession = _model.startChat(history: []);
  }
  
  // Offline fallback responses
  String _getOfflineResponse(String message) {
    if (message.toLowerCase().contains('relapse')) {
      return _getDefaultRelapseSupport();
    } else if (message.toLowerCase().contains('craving')) {
      return 'Cravings are temporary. Try the 5-minute rule: wait 5 minutes before acting on the craving. Use this time to practice deep breathing or call a support person.';
    } else if (message.toLowerCase().contains('stressed') || message.toLowerCase().contains('anxious')) {
      return 'Stress and anxiety are common triggers. Try grounding techniques: name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.';
    } else {
      return 'I hear you. Recovery is a journey with ups and downs. Focus on the progress you\'ve made and take it one moment at a time. You\'re stronger than you know.';
    }
  }
  
  String _getDefaultMotivationalQuote() {
    final quotes = [
      'Every day clean is a victory worth celebrating.',
      'Your strength is greater than any craving.',
      'Progress, not perfection, is the goal.',
      'You\'ve survived 100% of your worst days.',
      'Recovery is possible, and you\'re proving it.',
    ];
    return quotes[DateTime.now().millisecond % quotes.length];
  }
  
  String _getDefaultDailyTip() {
    final tips = [
      'Start your day with gratitude - write down three things you\'re thankful for.',
      'Replace old habits with new ones - when you feel a craving, go for a walk.',
      'Stay hydrated and maintain regular meals to keep your mood stable.',
      'Connect with your support network - isolation feeds addiction.',
      'Practice the HALT check: Are you Hungry, Angry, Lonely, or Tired?',
    ];
    return tips[DateTime.now().millisecond % tips.length];
  }
  
  String _getDefaultRelapseSupport() {
    return 'A relapse doesn\'t erase your progress. It\'s a bump in the road, not the end of your journey. Be kind to yourself, learn from what triggered it, and start fresh right now. Your recovery is still valid, and you\'re still capable of success.';
  }
  
  List<String> _getDefaultCopingStrategies() {
    return [
      'Take 10 deep breaths, counting slowly to 4 on inhale and 6 on exhale',
      'Call or text someone from your support network',
      'Engage in physical activity for at least 15 minutes',
      'Practice the 5-4-3-2-1 grounding technique',
      'Write down your feelings in a journal',
    ];
  }
}
