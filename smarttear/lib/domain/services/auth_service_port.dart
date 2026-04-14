import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_service_port.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    required String email,
  }) = _AuthUser;
}

sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  final AuthUser user;
}

class AuthFailure extends AuthResult {
  const AuthFailure(this.message);

  final String message;
}

abstract class AuthServicePort {
  Future<AuthResult> signIn(String email, String password);
  Future<AuthResult> register(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Stream<AuthUser?> get authStateStream;
  AuthUser? get currentUser;
}

