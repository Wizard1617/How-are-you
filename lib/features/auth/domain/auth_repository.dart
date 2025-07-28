import 'package:firebase_auth/firebase_auth.dart';

/// Абстрактный репозиторий для аутентификации.
/// Определяет интерфейс, который должен реализовать конкретный сервис.
/// Это позволяет отделить логику доступа к данным от UI и легко менять реализацию,
/// например, для тестирования или замены Firebase.
abstract class AuthRepository {
  /// Запускает процесс верификации номера телефона.
  /// При успешной отправке кода вызывает [onCodeSent].
  /// При ошибках вызывает [onFailed].
  /// При успешной автоматической верификации вызывает [onCompleted].
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
    required Function(PhoneAuthCredential) onCompleted,
  });

  /// Авторизация по SMS коду с указанием verificationId.
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// Текущий пользователь (null, если не авторизован)
  User? get currentUser;

  /// Выход из аккаунта
  Future<void> signOut();
}
