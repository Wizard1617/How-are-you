class HistoryModel {
  final String emotion;
  final String comment;
  final String response;
  final DateTime date;

  HistoryModel({
    required this.emotion,
    required this.comment,
    required this.response,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'emotion': emotion,
    'comment': comment,
    'response': response,
    'date': date.toIso8601String(),
  };

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    emotion: json['emotion'],
    comment: json['comment'],
    response: json['response'],
    date: DateTime.parse(json['date']),
  );
}
