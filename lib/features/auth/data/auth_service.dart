import 'package:firebase_auth/firebase_auth.dart';

/// Сервис для работы с Firebase Authentication, реализующий авторизацию по телефону.
/// Отвечает за отправку SMS кода, верификацию кода и управление сессией пользователя.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Сохраняем verificationId, который нужен для подтверждения SMS-кода позже
  String? _verificationId;

  /// Отправляет SMS с кодом на указанный номер телефона.
  /// 
  /// [phoneNumber] — номер в формате с +7 (Россия).
  /// [codeSentCallback] — коллбек, который вызывается после успешной отправки кода,
  /// чтобы, например, перейти на экран ввода кода.
  Future<void> sendCode(String phoneNumber, void Function() codeSentCallback) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60), // время ожидания автоматической проверки кода
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Автоматическая авторизация, если система смогла самостоятельно подтвердить номер
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Обработка ошибки верификации — например, неправильный формат номера
        throw Exception('Ошибка верификации: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Сохраняем verificationId, который нужен для подтверждения кода
        _verificationId = verificationId;
        codeSentCallback(); // вызываем коллбек для перехода на следующий экран
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Таймаут автоматического получения кода — обновляем verificationId
        _verificationId = verificationId;
      },
    );
  }

  /// Подтверждение SMS кода, введенного пользователем.
  /// Генерирует учетные данные и логинит пользователя.
  Future<void> verifyCode(String smsCode) async {
    if (_verificationId == null) throw Exception('Нет verificationId для подтверждения кода');

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }

  /// Проверяет, авторизован ли сейчас пользователь
  bool isLoggedIn() => _auth.currentUser != null;

  /// Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
