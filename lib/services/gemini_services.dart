// services/gemini_services.dart - Enhanced AI Integration
import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/water_analysis.dart';

class GeminiService {
  // Replace with your actual API key
  static const String apiKey = 'AIzaSyCYKWkIrO5ddPynMHV7fWScjRBBTKshoS0';
  static late GenerativeModel _model;
  static late GenerativeModel _chatModel;
  static bool _isInitialized = false;
  
  static void initialize() {
    if (!_isInitialized) {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      
      // Separate model for chatbot with different settings
      _chatModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 512,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      
      _isInitialized = true;
    }
  }
  
  // Enhanced water analysis with better pH and temperature detection
  static Future<Map<String, dynamic>> analyzeWaterImageWithClassification(List<int> imageBytes) async {
    try {
      if (!_isInitialized) initialize();
      
      final prompt = '''
      Analisis gambar air ini dengan teliti dan berikan output dalam format JSON yang tepat.

      Sebagai pakar kualiti air, klasifikasikan berdasarkan ciri visual yang dapat diperhatikan:

      PANDUAN KLASIFIKASI:
      1. HIGH_PH - Air kelihatan keruh keputihan, mungkin ada endapan mineral, permukaan berkilat
      2. HIGH_PH_LOW_TEMP - Air keruh keputihan dengan tanda-tanda sejuk (tiada wap, permukaan tenang)
      3. LOW_PH - Air kelihatan jernih tetapi mungkin berbau atau berwarna sedikit kekuningan
      4. LOW_TEMP_HIGH_PH - Air sejuk (tiada wap) tetapi keruh atau berbuih
      5. LOW_TEMP - Air kelihatan sejuk, tiada wap, permukaan tenang, mungkin ada ais atau embun
      6. OPTIMUM - Air jernih, bersih, tidak berwarna, kelihatan segar dan sihat

      PETUNJUK VISUAL:
      - Warna: Jernih (baik), keruh (pH masalah), kekuningan (asid), keputihan (alkali)
      - Kejelasan: Boleh nampak dasar (baik), keruh (masalah)
      - Permukaan: Tenang (sejuk), berbuih (pH tinggi), berminyak (tercemar)
      - Konteks: Ada wap (panas), tiada wap (sejuk), dalam botol (dirawat), sumber asli

      Output JSON format:
      {
        "category": "[kategori berdasarkan analisis di atas]",
        "confidence": [nombor 0-100 berdasarkan kejelasan gambar],
        "explanation": "[penjelasan 2-3 ayat dalam BM mengapa kategori ini dipilih]",
        "water_detected": [true jika ada air dalam gambar],
        "water_quality_class": "[Bersih/Sederhana/Tercemar berdasarkan keseluruhan penampilan]"
      }

      Berikan analisis yang tepat berdasarkan apa yang benar-benar kelihatan dalam gambar.
      ''';
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];
      
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        try {
          // Clean and parse JSON response
          final jsonStr = response.text!.trim();
          final cleanJson = jsonStr
              .replaceAll(RegExp(r'```json\s*'), '')
              .replaceAll(RegExp(r'```\s*'), '')
              .replaceAll(RegExp(r'^[^{]*'), '')
              .replaceAll(RegExp(r'[^}]*$'), '');
          
          final Map<String, dynamic> result = json.decode(cleanJson);
          
          // Validate and set defaults
          result['category'] = result['category'] ?? 'OPTIMUM';
          result['confidence'] = (result['confidence'] ?? 75).toDouble();
          result['explanation'] = result['explanation'] ?? 'Analisis air menunjukkan keadaan yang dapat diterima.';
          result['water_detected'] = result['water_detected'] ?? true;
          result['water_quality_class'] = result['water_quality_class'] ?? 'Sederhana';
          
          // Ensure confidence is within valid range
          if (result['confidence'] < 0 || result['confidence'] > 100) {
            result['confidence'] = 75.0;
          }
          
          return result;
        } catch (e) {
          print('Error parsing Gemini JSON: $e');
          return _getDefaultAnalysis();
        }
      } else {
        throw Exception('Empty response from Gemini');
      }
    } catch (e) {
      print('Error in Gemini analysis: $e');
      return _getDefaultAnalysis();
    }
  }

  // Enhanced water recommendation with more practical advice
  static Future<String> getWaterRecommendation(WaterAnalysis analysis) async {
    try {
      if (!_isInitialized) initialize();
      
      final prompt = '''
      Sebagai pakar kualiti air di Malaysia, berikan cadangan praktikal berdasarkan analisis:

      KEPUTUSAN ANALISIS:
      - Kategori: ${analysis.waterQualityClass}
      - Keyakinan: ${analysis.confidence}%
      - Status: ${analysis.qualityMalay}
      - Penjelasan: ${analysis.categoryDescription}

      Berikan cadangan dalam bahasa Melayu yang:
      1. Mudah difahami oleh masyarakat Malaysia
      2. Praktikal dan boleh dilaksanakan
      3. Mengambil kira konteks tempatan (iklim tropika, sumber air tempatan)
      4. Fokus pada keselamatan kesihatan

      Format jawapan (maksimum 3 ayat):
      • Keselamatan: [Adakah selamat diminum?]
      • Tindakan: [Apa yang perlu dilakukan segera?]
      • Pencegahan: [Langkah pencegahan untuk masa depan]

      Guna bahasa yang tidak menakutkan tetapi jelas tentang risiko.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return _getDefaultRecommendation(analysis);
      }
    } catch (e) {
      print('Error getting recommendation: $e');
      return _getDefaultRecommendation(analysis);
    }
  }

  // Chatbot response for user assistance
  static Future<String> getChatbotResponse(String prompt) async {
    try {
      if (!_isInitialized) initialize();
      
      final content = [Content.text(prompt)];
      final response = await _chatModel.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return 'Maaf, saya tidak dapat memahami soalan anda. Boleh cuba tanya dengan cara lain?';
      }
    } catch (e) {
      print('Error in chatbot response: $e');
      return 'Saya mengalami masalah teknikal. Boleh cuba tanya soalan lain dalam beberapa saat?';
    }
  }

  // Community advice based on multiple reports
  static Future<String> getCommunityAdvice(String issueType, String location) async {
    try {
      if (!_isInitialized) initialize();
      
      final prompt = '''
      Sebagai penasihat komuniti untuk isu air di Malaysia:

      SITUASI:
      - Lokasi: $location
      - Jenis masalah: $issueType

      Berikan nasihat komuniti dalam bahasa Melayu yang:
      1. Sesuai untuk konteks Malaysia (cuaca tropika, infrastruktur tempatan)
      2. Fokus pada tindakan komuniti bersama
      3. Rujuk kepada agensi tempatan yang sesuai
      4. Praktikal dan mudah dilaksanakan

      Format jawapan (4 poin maksimum):
      • Tindakan segera komuniti
      • Siapa yang perlu dihubungi (agensi Malaysia)
      • Langkah pencegahan jangka panjang
      • Monitoring berterusan

      Guna poin bullet pendek dan jelas.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return _getDefaultCommunityAdvice(location);
      }
    } catch (e) {
      print('Error getting community advice: $e');
      return _getDefaultCommunityAdvice(location);
    }
  }

  // Health impact analysis
  static Future<String> getHealthImpact(String waterQuality, List<String> symptoms) async {
    try {
      if (!_isInitialized) initialize();
      
      final symptomsText = symptoms.join(', ');
      final prompt = '''
      Sebagai pakar kesihatan awam di Malaysia, analisis impak kesihatan:

      DATA:
      - Kualiti air: $waterQuality
      - Simptom dilaporkan: $symptomsText

      Berikan analisis dalam bahasa Melayu yang:
      1. Jelaskan hubungan air-kesihatan secara saintifik tetapi mudah faham
      2. Fokus pada situasi Malaysia (iklim panas lembap, penyakit tropika)
      3. Tekankan kumpulan berisiko tinggi
      4. Cadangan tindakan kesihatan yang praktikal

      Gunakan bahasa yang bertanggungjawab - jelas tetapi tidak menimbulkan panik.
      Maksimum 4 ayat dengan maklumat yang tepat.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return _getDefaultHealthAdvice(waterQuality);
      }
    } catch (e) {
      print('Error getting health impact: $e');
      return _getDefaultHealthAdvice(waterQuality);
    }
  }

  // Flood risk analysis with weather data
  static Future<Map<String, dynamic>> analyzeFloodRisk({
    required double latitude,
    required double longitude,
    required int humidity,
    required String weatherCondition,
    required double temperature,
  }) async {
    try {
      if (!_isInitialized) initialize();
      
      final prompt = '''
      Analisis risiko banjir untuk lokasi di Malaysia:

      DATA LOKASI:
      - Koordinat: $latitude, $longitude
      - Kelembapan: $humidity%
      - Cuaca: $weatherCondition
      - Suhu: $temperature°C

      Berdasarkan pengetahuan geografi Malaysia dan data cuaca, berikan analisis dalam JSON:

      {
        "risk_level": "[RENDAH/SEDERHANA/TINGGI]",
        "confidence": [0-100],
        "reasoning": "[penjelasan 2-3 ayat mengapa tahap ini dipilih]",
        "recommendations": ["cadangan1", "cadangan2", "cadangan3"],
        "immediate_action_needed": [true/false],
        "weather_factors": {
          "humidity_impact": "[kesan kelembapan terhadap risiko]",
          "condition_impact": "[kesan kondisi cuaca]"
        }
      }

      Ambil kira:
      - Kelembapan >80% + hujan = risiko tinggi
      - Kawasan rendah Malaysia (pantai timur, delta)
      - Musim monsun dan pola hujan tempatan
      - Infrastruktur saliran Malaysia
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        try {
          final jsonStr = response.text!.trim();
          final cleanJson = jsonStr
              .replaceAll(RegExp(r'```json\s*'), '')
              .replaceAll(RegExp(r'```\s*'), '');
          
          return json.decode(cleanJson);
        } catch (e) {
          return _getDefaultFloodAnalysis(humidity, weatherCondition);
        }
      } else {
        return _getDefaultFloodAnalysis(humidity, weatherCondition);
      }
    } catch (e) {
      print('Error in flood analysis: $e');
      return _getDefaultFloodAnalysis(humidity, weatherCondition);
    }
  }

  // Legacy method for backward compatibility
  static Future<String> analyzeWaterImage(List<int> imageBytes) async {
    try {
      final result = await analyzeWaterImageWithClassification(imageBytes);
      return result['explanation'] ?? 'Analisis selesai.';
    } catch (e) {
      print('Error in legacy water analysis: $e');
      return 'Tidak dapat menganalisis gambar pada masa ini.';
    }
  }

  // Default fallback methods
  static Map<String, dynamic> _getDefaultAnalysis() {
    return {
      'category': 'OPTIMUM',
      'confidence': 50.0,
      'explanation': 'Analisis automatik menunjukkan air dalam keadaan yang boleh diterima. Untuk keputusan yang lebih tepat, pastikan gambar jelas dan pencahayaan mencukupi.',
      'water_detected': true,
      'water_quality_class': 'Sederhana'
    };
  }

  static String _getDefaultRecommendation(WaterAnalysis analysis) {
    switch (analysis.category) {
      case WaterQualityCategory.HIGH_PH:
        return '• Keselamatan: Air mungkin terlalu beralkali untuk diminum\n• Tindakan: Uji pH dengan kit ujian untuk pengesahan\n• Pencegahan: Periksa sumber air dan sistem penapisan';
      case WaterQualityCategory.LOW_PH:
        return '• Keselamatan: Air mungkin terlalu berasid, elakkan penggunaan terus\n• Tindakan: Neutralkan dengan penapisan atau didihkan dahulu\n• Pencegahan: Periksa punca pencemaran asid di kawasan';
      case WaterQualityCategory.LOW_TEMP:
        return '• Keselamatan: Air sejuk biasanya selamat tetapi perlu dipanaskan untuk minum\n• Tindakan: Panaskan air sebelum diminum untuk keselamatan\n• Pencegahan: Pastikan sumber air bersih dan tidak tercemar';
      default:
        return '• Keselamatan: Air kelihatan dalam keadaan normal\n• Tindakan: Pastikan air dari sumber yang dipercayai\n• Pencegahan: Simpan air dalam bekas bersih dan tertutup';
    }
  }

  static String _getDefaultCommunityAdvice(String location) {
    return '''• Hubungi Jabatan Bekalan Air tempatan untuk laporan
• Kumpulkan bukti (gambar, sampel air) untuk siasatan
• Maklumkan kepada Jabatan Kesihatan Negeri jika ada isu kesihatan
• Pantau situasi secara berkala dan kongsikan maklumat dengan jiran''';
  }

  static String _getDefaultHealthAdvice(String waterQuality) {
    return '''Air yang tidak berkualiti boleh menyebabkan masalah penghadaman, jangkitan kulit, dan masalah kesihatan lain. Kanak-kanak, warga emas, dan mereka yang kurang sihat berisiko lebih tinggi. Jika mengalami simptom selepas guna air, hentikan penggunaan dan dapatkan rawatan perubatan. Pastikan guna air yang selamat untuk minum dan memasak.''';
  }

  static Map<String, dynamic> _getDefaultFloodAnalysis(int humidity, String condition) {
    String riskLevel = 'SEDERHANA';
    bool immediateAction = false;
    
    if (humidity > 80 && condition.toLowerCase().contains('hujan')) {
      riskLevel = 'TINGGI';
      immediateAction = true;
    } else if (humidity < 50 && !condition.toLowerCase().contains('hujan')) {
      riskLevel = 'RENDAH';
    }
    
    return {
      'risk_level': riskLevel,
      'confidence': 70,
      'reasoning': 'Analisis berdasarkan data kelembapan dan kondisi cuaca semasa.',
      'recommendations': [
        'Pantau ramalan cuaca secara berkala',
        'Pastikan sistem saliran tidak tersumbat',
        'Sediakan pelan pemindahan kecemasan'
      ],
      'immediate_action_needed': immediateAction,
      'weather_factors': {
        'humidity_impact': 'Kelembapan $humidity% ${humidity > 70 ? 'meningkatkan' : 'tidak meningkatkan'} risiko hujan lebat',
        'condition_impact': 'Kondisi $condition ${condition.toLowerCase().contains('hujan') ? 'meningkatkan' : 'tidak meningkatkan'} risiko banjir'
      }
    };
  }
}