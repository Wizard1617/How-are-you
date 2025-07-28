/// Модель данных, описывающая ответ от сервера
class AiResponseModel {
  final String response;

  AiResponseModel({required this.response});

  /// Метод для парсинга JSON в модель
  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(response: json['response'] as String);
  }
}
