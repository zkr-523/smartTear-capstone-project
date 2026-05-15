import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/services/auth_service_port.dart';

class FirebaseAuthService implements AuthServicePort {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FirebaseAuth _auth;
  final FlutterSecureStorage _secureStorage;

  static const _currentUserIdKey = 'current_user_id';

  @override
  Stream<AuthUser?> get authStateStream =>
      _auth.authStateChanges().map(_mapFirebaseUser);

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  /// Firebase [User.email] can be null on some platforms (e.g. web restore).
  /// We still treat the session as signed-in using [User.uid].
  AuthUser? _mapFirebaseUser(User? u) {
    if (u == null) return null;
    final email = u.email?.trim();
    return AuthUser(uid: u.uid, email: (email != null && email.isNotEmpty) ? email : '');
  }

  @override
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final u = cred.user;
      final uEmail = u?.email;
      if (u == null || uEmail == null) {
        return const AuthFailure('Sign-in failed. Try again.');
      }

      await _secureStorage.write(key: _currentUserIdKey, value: u.uid);
      return AuthSuccess(AuthUser(uid: u.uid, email: uEmail));
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapAuthError(e.code));
    } catch (_) {
      return const AuthFailure('Sign-in failed. Try again.');
    }
  }

  @override
  Future<AuthResult> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final u = cred.user;
      final uEmail = u?.email;
      if (u == null || uEmail == null) {
        return const AuthFailure('Registration failed. Try again.');
      }

      return AuthSuccess(AuthUser(uid: u.uid, email: uEmail));
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapAuthError(e.code));
    } catch (_) {
      return const AuthFailure('Registration failed. Try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _currentUserIdKey);
    await _auth.signOut();
  }

  @override
  Future<String?> deleteAccount() async {
    try {
      final u = _auth.currentUser;
      if (u == null) return 'Not signed in';
      await u.delete();
      await _secureStorage.delete(key: _currentUserIdKey);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (_) {
      return 'Could not delete account. Try again.';
    }
  }

  @override
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (_) {
      return 'Could not send reset email. Try again.';
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Try again in 15 minutes.';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'network-request-failed':
        return 'No internet connection';
      case 'invalid-credential':
        return 'Incorrect email or password';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}

