// providers/chatbot_provider.dart - AI Chatbot for Water Quality Assistance
import 'package:flutter/material.dart';
import '../services/gemini_services.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });
}

class ChatbotProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Predefined quick questions for better UX
  final List<String> quickQuestions = [
    'Bagaimana cara mengetahui air bersih?',
    'Apa tanda-tanda air tercemar?',
    'Bolehkah air hujan diminum?',
    'Bagaimana cara menyaring air?',
    'Apa itu pH air?',
    'Kenapa kelembapan penting?',
    'Bagaimana mengelak banjir?',
    'Apa yang perlu dilakukan jika air berubah warna?',
  ];

  ChatbotProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    _messages.add(
      ChatMessage(
        text: 'Selamat datang ke NadiAir Assistant! 🌊\n\nSaya di sini untuk membantu anda memahami:\n• Kualiti air dan keselamatan\n• Cara membaca hasil analisis\n• Tips pencegahan pencemaran\n• Maklumat tentang risiko banjir\n\nApa yang ingin anda ketahui hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    // Show typing indicator
    _isLoading = true;
    _messages.add(
      ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isTyping: true,
      ),
    );
    notifyListeners();

    try {
      // Get AI response
      final response = await _getAIResponse(message);
      
      // Remove typing indicator
      _messages.removeWhere((msg) => msg.isTyping);
      
      // Add AI response
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // Remove typing indicator
      _messages.removeWhere((msg) => msg.isTyping);
      
      // Add error message
      _messages.add(
        ChatMessage(
          text: 'Maaf, saya mengalami masalah teknikal. Boleh cuba tanya soalan lain?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    final prompt = '''
    Anda adalah AI assistant untuk aplikasi NadiAir yang membantu pengguna tentang kualiti air, keselamatan air, dan risiko banjir di Malaysia.

    Pengguna bertanya: "$userMessage"

    Berikan jawapan yang:
    1. Mudah difahami dalam Bahasa Melayu
    2. Praktikal dan berguna
    3. Berkaitan dengan kualiti air, kesihatan, atau keselamatan
    4. Tidak lebih dari 200 perkataan
    5. Gunakan emoji yang sesuai untuk memudahkan pembacaan

    Topik yang anda pakar:
    - Kualiti air dan ujian pH/suhu
    - Tanda-tanda pencemaran air
    - Cara memastikan air selamat diminum
    - Sistem penapisan air
    - Risiko kesihatan dari air tercemar
    - Pencegahan banjir dan langkah keselamatan
    - Kelembapan dan kesan terhadap kualiti air

    Jika soalan di luar bidang ini, terangkan dengan sopan bahawa anda fokus pada isu air dan cadangkan soalan yang berkaitan.
    ''';

    try {
      final response = await GeminiService.getChatbotResponse(prompt);
      return response;
    } catch (e) {
      return _getFallbackResponse(userMessage);
    }
  }

  String _getFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('bersih') || lowerMessage.contains('kualiti')) {
      return '💧 Air bersih mempunyai ciri-ciri:\n• Tidak berwarna dan tidak berbau\n• Tiada rasa pelik\n• pH antara 6.5-8.5\n• Bebas dari bakteria berbahaya\n\nGunakan fungsi scan NadiAir untuk analisis pantas!';
    } else if (lowerMessage.contains('tercemar') || lowerMessage.contains('kotor')) {
      return '⚠️ Tanda air tercemar:\n• Warna keruh atau berubah\n• Bau busuk atau kimia\n• Rasa metalik atau pahit\n• Buih berlebihan\n\nJangan minum air yang mencurigakan! Hubungi pihak berkuasa jika perlu.';
    } else if (lowerMessage.contains('ph')) {
      return '🧪 pH air yang selamat:\n• pH 6.5-8.5 = Selamat diminum\n• pH <6.5 = Terlalu berasid\n• pH >8.5 = Terlalu beralkali\n\nNadiAir boleh mengesan pH melalui analisis gambar!';
    } else if (lowerMessage.contains('banjir')) {
      return '🌊 Tips pencegahan banjir:\n• Pantau ramalan cuaca\n• Bersihkan longkang sekitar rumah\n• Sediakan pelan pemindahan\n• Simpan bekalan darurat\n\nGunakan fungsi deteksi banjir NadiAir untuk amaran awal!';
    } else {
      return '🤔 Saya fokus membantu isu berkaitan air dan banjir.\n\nCuba tanya tentang:\n• Kualiti dan keselamatan air\n• Cara mengenal air bersih\n• Pencegahan pencemaran\n• Risiko banjir\n\nApa yang ingin anda ketahui?';
    }
  }

  void sendQuickQuestion(String question) {
    sendMessage(question);
  }

  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }
}