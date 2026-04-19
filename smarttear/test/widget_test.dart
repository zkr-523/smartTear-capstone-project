import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smarttear/firebase_options.dart';
import 'package:smarttear/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('App boots with router', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // We start at /splash but may immediately redirect based on auth/onboarding.
    expect(
      find.textContaining('Splash').evaluate().isNotEmpty ||
          find.textContaining('Sign In').evaluate().isNotEmpty ||
          find.textContaining('Onboarding').evaluate().isNotEmpty ||
          find.textContaining('SmartTear').evaluate().isNotEmpty,
      isTrue,
    );
  });
}
