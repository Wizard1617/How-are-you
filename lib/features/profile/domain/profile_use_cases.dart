import 'package:emotion_gpt_app/features/profile/data/profile_repository.dart';

/// UseCases для профиля — бизнес-логика, вызываемая из UI.
class ProfileUseCases {
  final ProfileRepository _repo;

  ProfileUseCases(this._repo);

  /// Получение текущего пользователя.
  String getCurrentUserPhone() {
    return _repo.currentUser?.phoneNumber ?? 'Гость';
  }

  /// Очистка истории.
  Future<void> clearHistory() => _repo.clearHistory();

  /// Выход из аккаунта.
  Future<void> signOut() => _repo.signOut();

  /// Открытие Telegram.
  Future<bool> openTelegram(String url) {
    final uri = Uri.parse(url);
    return _repo.launchTelegram(uri);
  }
}
