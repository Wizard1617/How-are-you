import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai_response_model.dart';

/// Класс для общения с FastAPI-сервером, получающим ответ от YandexGPT
class AiResponseApi {
  // Базовый URL локального сервера (нужно заменить на прод-адрес при релизе)
  static const String _baseUrl = 'http://192.168.1.71:8000';

  /// Отправка эмоции и комментария на сервер и получение ответа от ИИ
  Future<AiResponseModel> fetchAiResponse(String emotion, String comment) async {
    final uri = Uri.parse('$_baseUrl/emotion');

    final response = await http.post(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emotion': emotion,
        'comment': comment,
      }),
    );

    // Обработка успешного ответа
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes); // корректная кодировка
      final json = jsonDecode(decoded);
      return AiResponseModel.fromJson(json);
    } else {
      // Обработка ошибки
      throw Exception('Ошибка при получении ответа от сервера');
    }
  }
}
