import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng nhập
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }

  // User hiện tại
  User? get currentUser {
    return _auth.currentUser;
  }

  // Theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}