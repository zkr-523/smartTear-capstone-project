import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/auth_service_port.dart';
import '../../infrastructure/auth/firebase_auth_service.dart';

final authServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateStream;
});
