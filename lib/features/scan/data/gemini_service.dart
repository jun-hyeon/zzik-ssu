import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'model/receipt_result.dart';

// Provider definition
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  // Retrieve API Key from .env
  String? get _apiKey => dotenv.env['GEMINI_API_KEY'];

  Future<ReceiptResult?> analyzeReceipt(File imageFile) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is missing. Please check your .env file.',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json', // Force JSON response
          temperature: 0.3, // Low creativity for factual extraction
        ),
      );

      final prompt = Content.text('''
        너는 한국 영수증 분석 전문가야. 이 이미지를 분석해서 다음 정보를 JSON으로 추출해.
        
        [규칙]
        1. storeName: 영수증 상단의 매장명 (지점명 포함).
        2. date: 결제 일시 (YYYY-MM-DD). 없으면 오늘 날짜.
        3. items: 구매한 상품 리스트.
           - name: 상품명 (할인, 포인트 적립 내역 등은 제외).
           - price: 상품의 **개당 단가** (총 금액 아님).
           - qty: 수량 (별도 표기가 없으면 1).
        4. totalAmount: 최종 결제 금액 (숫자만).
        
        [출력 포맷 예시]
        {
          "storeName": "이마트 역삼점",
          "date": "2024-01-20",
          "totalAmount": 12500,
          "items": [
            {"name": "서울우유 1L", "price": 2800, "qty": 1},
            {"name": "새우깡", "price": 3000, "qty": 2}
          ]
        }
      ''');

      final imageBytes = await imageFile.readAsBytes();
      final imagePart = Content.data('image/jpeg', imageBytes);

      final response = await model.generateContent([prompt, imagePart]);

      dev.log('Gemini Response: ${response.text}', name: 'GeminiService');

      if (response.text == null) return null;

      // Clean Markdown code blocks if present
      final cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return ReceiptResult.fromJson(jsonDecode(cleanJson));
    } catch (e) {
      dev.log('AI Analysis Failed', error: e, name: 'GeminiService');
      return null;
    }
  }
}
