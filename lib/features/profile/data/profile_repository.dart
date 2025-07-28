import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

/// Репозиторий профиля: содержит доступ к Firebase и внешним сервисам.
class ProfileRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Возвращает текущего пользователя.
  User? get currentUser => _auth.currentUser;

  /// Выход из аккаунта.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Очистка истории пользователя в Firestore.
  Future<void> clearHistory() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final historyRef = _firestore.collection('users').doc(uid).collection('history');
    final snapshot = await historyRef.get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Открытие Telegram-ссылки.
  Future<bool> launchTelegram(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
