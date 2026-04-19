import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kEstBgEnabledKey = 'est_bg_enabled';

final estBgSettingsNotifierProvider =
    AsyncNotifierProvider<EstBgSettingsNotifier, bool>(
  EstBgSettingsNotifier.new,
);

class EstBgSettingsNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    const storage = FlutterSecureStorage();
    final v = await storage.read(key: _kEstBgEnabledKey);
    return v == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: _kEstBgEnabledKey,
      value: enabled ? 'true' : 'false',
    );
    state = AsyncData(enabled);
  }
}
