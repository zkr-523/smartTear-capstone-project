import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kTgLagSeconds = 'tg_lag_seconds';
const _kTgScale = 'tg_scale';
const _kTgOffset = 'tg_offset';

const double kDefaultTgLagSeconds = 600;
const double kDefaultTgScale = 18.0;
const double kDefaultTgOffset = 0.0;

/// Persisted TG→BG mapping parameters (lag / scale / offset).
class TgBgSettingsData {
  const TgBgSettingsData({
    required this.lagSeconds,
    required this.scale,
    required this.offset,
  });

  final double lagSeconds;
  final double scale;
  final double offset;

  static const defaults = TgBgSettingsData(
    lagSeconds: kDefaultTgLagSeconds,
    scale: kDefaultTgScale,
    offset: kDefaultTgOffset,
  );
}

final tgBgSettingsNotifierProvider =
    AsyncNotifierProvider<TgBgSettingsNotifier, TgBgSettingsData>(
  TgBgSettingsNotifier.new,
);

class TgBgSettingsNotifier extends AsyncNotifier<TgBgSettingsData> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<TgBgSettingsData> build() async {
    final lag = double.tryParse(await _storage.read(key: _kTgLagSeconds) ?? '') ??
        kDefaultTgLagSeconds;
    final scale =
        double.tryParse(await _storage.read(key: _kTgScale) ?? '') ??
            kDefaultTgScale;
    final offset =
        double.tryParse(await _storage.read(key: _kTgOffset) ?? '') ??
            kDefaultTgOffset;
    return TgBgSettingsData(
      lagSeconds: lag,
      scale: scale,
      offset: offset,
    );
  }

  Future<void> save({
    required double lagSeconds,
    required double scale,
    required double offset,
  }) async {
    await _storage.write(key: _kTgLagSeconds, value: lagSeconds.toString());
    await _storage.write(key: _kTgScale, value: scale.toString());
    await _storage.write(key: _kTgOffset, value: offset.toString());
    state = AsyncData(
      TgBgSettingsData(
        lagSeconds: lagSeconds,
        scale: scale,
        offset: offset,
      ),
    );
  }

  Future<void> resetToDefaults() async {
    await save(
      lagSeconds: kDefaultTgLagSeconds,
      scale: kDefaultTgScale,
      offset: kDefaultTgOffset,
    );
  }
}
