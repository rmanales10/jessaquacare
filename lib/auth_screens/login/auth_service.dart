import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await _auth.signOut();
        return "Please verify your email before signing in.";
      }

      return null; // No error
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
