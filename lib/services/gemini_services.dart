// services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/water_analysis.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyCYKWkIrO5ddPynMHV7fWScjRBBTKshoS0';
  static late GenerativeModel _model;
  
  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }
  
  static Future<String> getWaterRecommendation(WaterAnalysis analysis) async {
    try {
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
      
      return response.text ?? 'Tidak dapat memberikan cadangan pada masa ini.';
    } catch (e) {
      return 'Ralat mendapatkan cadangan: $e';
    }
  }
  
  static Future<String> getCommunityAdvice(String issueType, String location) async {
    try {
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
      
      return response.text ?? 'Tidak dapat memberikan nasihat pada masa ini.';
    } catch (e) {
      return 'Ralat mendapatkan nasihat: $e';
    }
  }
  
  static Future<String> getHealthImpact(String waterQuality, List<String> symptoms) async {
    try {
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
      
      return response.text ?? 'Tidak dapat memberikan maklumat kesihatan pada masa ini.';
    } catch (e) {
      return 'Ralat mendapatkan maklumat kesihatan: $e';
    }
  }
}