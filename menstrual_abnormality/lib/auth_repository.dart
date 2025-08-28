// filepath: lib/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult({required this.success, this.errorMessage});
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is already signed in
  User? get currentUser => _auth.currentUser;

  // Listen to auth state changes (real-time)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // In auth_repository.dart
  User? getCurrentUser() {
    return _auth.currentUser;
  }


  // ---------------- Email/Password Sign Up ----------------
  Future<AuthResult> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ---------------- Email/Password Sign In ----------------
  Future<AuthResult> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ---------------- Google Sign In ----------------
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(success: false, errorMessage: "Google sign-in aborted");
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ---------------- Google Sign Up ----------------
  Future<AuthResult> signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(success: false, errorMessage: "Google sign-up aborted");
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ---------------- Apple Sign In ----------------
  Future<AuthResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ---------------- Sign Out ----------------
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
