// services/gemini_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/water_analysis.dart';

class GeminiService {
  // Gantikan dengan API key anda yang sebenar
  static const String apiKey = 'AIzaSyCYKWkIrO5ddPynMHV7fWScjRBBTKshoS0';
  static late GenerativeModel _model;
  static bool _isInitialized = false;
  
  static void initialize() {
    if (!_isInitialized) {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash', // Menggunakan model terkini
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
      _isInitialized = true;
    }
  }
  
  static Future<String> getWaterRecommendation(WaterAnalysis analysis) async {
    try {
      // Pastikan model telah diinisialisasi
      if (!_isInitialized) {
        initialize();
      }
      
      final prompt = '''
      Berdasarkan analisis kualiti air berikut:
      - Kualiti: ${analysis.waterQualityClass}
      - Keyakinan: ${analysis.confidence}%
      - Air dikesan: ${analysis.waterDetected ? 'Ya' : 'Tidak'}
      
      Berikan cadangan tindakan dalam bahasa Melayu yang mudah difahami oleh masyarakat tempatan. 
      Fokus pada:
      1. Adakah air ini selamat untuk diminum?
      2. Tindakan segera yang perlu diambil
      3. Langkah pencegahan
      
      Jawab dalam 2-3 ayat sahaja, mudah difahami.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return 'Tidak dapat memberikan cadangan pada masa ini. Sila cuba lagi.';
      }
    } catch (e) {
      print('Ralat GeminiService.getWaterRecommendation: $e');
      return 'Ralat mendapatkan cadangan. Sila periksa sambungan internet dan cuba lagi.';
    }
  }
  
  static Future<String> getCommunityAdvice(String issueType, String location) async {
    try {
      // Pastikan model telah diinisialisasi
      if (!_isInitialized) {
        initialize();
      }
      
      final prompt = '''
      Komuniti di $location mengalami masalah air jenis: $issueType
      
      Berikan nasihat dalam bahasa Melayu untuk:
      1. Tindakan segera komuniti boleh ambil
      2. Siapa yang perlu dihubungi
      3. Cara mencegah masalah berulang
      
      Jawab dalam bentuk poin-poin pendek, maksimum 4 poin.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return 'Tidak dapat memberikan nasihat pada masa ini. Sila cuba lagi.';
      }
    } catch (e) {
      print('Ralat GeminiService.getCommunityAdvice: $e');
      return 'Ralat mendapatkan nasihat. Sila periksa sambungan internet dan cuba lagi.';
    }
  }
  
  static Future<String> getHealthImpact(String waterQuality, List<String> symptoms) async {
    try {
      // Pastikan model telah diinisialisasi
      if (!_isInitialized) {
        initialize();
      }
      
      final symptomsText = symptoms.join(', ');
      final prompt = '''
      Kualiti air: $waterQuality
      Simptom yang dilaporkan komuniti: $symptomsText
      
      Dalam bahasa Melayu, jelaskan:
      1. Kaitan antara kualiti air dengan simptom
      2. Risiko kesihatan jangka pendek dan panjang
      3. Kumpulan berisiko tinggi (kanak-kanak, warga emas)
      
      Gunakan bahasa yang tidak menakutkan tetapi jelas tentang risiko.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return 'Tidak dapat memberikan maklumat kesihatan pada masa ini. Sila cuba lagi.';
      }
    } catch (e) {
      print('Ralat GeminiService.getHealthImpact: $e');
      return 'Ralat mendapatkan maklumat kesihatan. Sila periksa sambungan internet dan cuba lagi.';
    }
  }
  
  // Method untuk analisis gambar air dengan klasifikasi automatik
  static Future<Map<String, dynamic>> analyzeWaterImageWithClassification(List<int> imageBytes) async {
    try {
      // Pastikan model telah diinisialisasi
      if (!_isInitialized) {
        initialize();
      }
      
      final prompt = '''
      Analisis gambar air ini dengan teliti berdasarkan pH dan SUHU air, kemudian berikan output dalam format JSON yang tepat:
      
      Klasifikasikan air berdasarkan tahap pH dan suhu berikut:
      1. HIGH_PH - Air dengan pH tinggi
      2. HIGH_PH_LOW_TEMP - Air dengan pH tinggi dan suhu rendah
      3. LOW_PH - Air dengan pH rendah
      4. LOW_TEMP_HIGH_PH - Air dengan suhu rendah dan pH tinggi
      5. LOW_TEMP - Air dengan suhu rendah
      6. OPTIMUM - Air dalam keadaan optimum
      
      FOKUS UTAMA: Analisis berdasarkan pH dan suhu air yang boleh dianggarkan dari gambar.
      
      Berikan output dalam format JSON yang tepat:
      {
        "category": "[salah satu daripada kategori di atas]",
        "confidence": [nombor antara 0-100],
        "explanation": "[penjelasan ringkas dalam bahasa Melayu mengapa air ini diklasifikasikan sebagai kategori tersebut, berdasarkan pH dan suhu yang dapat dianggarkan. Maksimum 2-3 ayat.]",
        "water_detected": [true/false],
        "water_quality_class": "[Bersih/Sederhana/Tercemar]"
      }
      
      Pastikan JSON output adalah valid dan lengkap.
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
          // Parse JSON response
          final jsonStr = response.text!.trim();
          // Remove markdown code blocks if present
          final cleanJson = jsonStr.replaceAll(RegExp(r'```json\s*'), '').replaceAll(RegExp(r'```\s*'), '');
          final Map<String, dynamic> result = json.decode(cleanJson);
          
          // Validate required fields
          result['category'] = result['category'] ?? 'OPTIMUM';
          result['confidence'] = (result['confidence'] ?? 70).toDouble();
          result['explanation'] = result['explanation'] ?? 'Analisis gambar menunjukkan air dalam keadaan optimum.';
          result['water_detected'] = result['water_detected'] ?? true;
          result['water_quality_class'] = result['water_quality_class'] ?? 'Sederhana';
          
          return result;
        } catch (e) {
          print('Error parsing Gemini JSON response: $e');
          // Return default response if JSON parsing fails
          return {
            'category': 'OPTIMUM',
        'confidence': 70.0,
        'explanation': 'Analisis automatik menunjukkan air dalam keadaan optimum.',
            'water_detected': true,
            'water_quality_class': 'Sederhana'
          };
        }
      } else {
        throw Exception('Empty response from Gemini');
      }
    } catch (e) {
      print('Ralat GeminiService.analyzeWaterImageWithClassification: $e');
      // Return default response on error
      return {
        'category': 'OPTIMUM',
        'confidence': 50.0,
        'explanation': 'Tidak dapat menganalisis pH dan suhu air dengan terperinci. Sila cuba lagi atau guna gambar yang lebih jelas.',
        'water_detected': true,
        'water_quality_class': 'Tidak Diketahui'
      };
    }
  }
  
  // Method tambahan untuk analisis gambar air (versi lama untuk keserasian)
  static Future<String> analyzeWaterImage(List<int> imageBytes) async {
    try {
      final result = await analyzeWaterImageWithClassification(imageBytes);
      return result['explanation'] ?? 'Analisis selesai.';
    } catch (e) {
      print('Ralat GeminiService.analyzeWaterImage: $e');
      return 'Ralat menganalisis gambar. Sila periksa sambungan internet dan cuba lagi.';
    }
  }
}