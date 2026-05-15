import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reading.dart';
import '../../infrastructure/ml/tg_bg_ml_model_provider.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';
import 'est_bg_settings_notifier.dart';

enum TrendsRange { d7, d30, d90, all }

/// Selected trends window. [TrendsNotifier] watches this so range changes always reload data.
final trendsRangeProvider =
    StateProvider<TrendsRange>((ref) => TrendsRange.d7);

class TgTrendStats {
  const TgTrendStats({
    required this.tgMin,
    required this.tgMax,
    required this.tgAvg,
    this.estMin,
    this.estMax,
    this.estAvg,
  });

  final double tgMin;
  final double tgMax;
  final double tgAvg;
  final double? estMin;
  final double? estMax;
  final double? estAvg;
}

class TrendsVm {
  const TrendsVm({
    required this.range,
    required this.readingsSorted,
    required this.tgReadings,
    this.stats,
    this.estimatedBgValues,
  });

  final TrendsRange range;
  /// In-range readings, oldest first.
  final List<Reading> readingsSorted;
  /// Subset with tear glucose, oldest first.
  final List<Reading> tgReadings;
  final TgTrendStats? stats;
  /// Parallel to [tgReadings] when Estimated BG is enabled.
  final List<double>? estimatedBgValues;
}

final trendsNotifierProvider =
    AsyncNotifierProvider<TrendsNotifier, TrendsVm>(TrendsNotifier.new);

class TrendsNotifier extends AsyncNotifier<TrendsVm> {
  @override
  Future<TrendsVm> build() async {
    final range = ref.watch(trendsRangeProvider);
    ref.watch(estBgSettingsNotifierProvider);
    return _load(range);
  }

  /// Updates [trendsRangeProvider]; Riverpod re-runs [build] and reloads filtered data.
  void setRange(TrendsRange range) {
    ref.read(trendsRangeProvider.notifier).state = range;
  }

  Future<TrendsVm> _load(TrendsRange range) async {
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      return TrendsVm(
        range: range,
        readingsSorted: const [],
        tgReadings: const [],
      );
    }

    final estBgEnabled =
        ref.watch(estBgSettingsNotifierProvider).valueOrNull ?? false;

    await ref.read(tgBgMlModelReadyProvider.future);
    final bgResolver = ref.read(estimatedBgResolverProvider);

    final repo = ref.read(readingRepositoryProvider);
    final all = await repo.listReadingsForUser(uid);
    final now = DateTime.now();
    final cutoff = switch (range) {
      TrendsRange.d7 => now.subtract(const Duration(days: 7)),
      TrendsRange.d30 => now.subtract(const Duration(days: 30)),
      TrendsRange.d90 => now.subtract(const Duration(days: 90)),
      TrendsRange.all => DateTime.fromMillisecondsSinceEpoch(0),
    };

    final filtered = all.where((r) => !r.takenAt.isBefore(cutoff)).toList()
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final tgReadings =
        filtered.where((r) => r.glucose != null).toList(growable: false);

    List<double>? estVals;
    if (estBgEnabled && tgReadings.isNotEmpty) {
      final parallel = bgResolver.parallelTo(tgReadings);
      if (parallel.every((v) => v != null)) {
        estVals = parallel.cast<double>().toList(growable: false);
      }
    }

    TgTrendStats? stats;
    if (tgReadings.length >= 2) {
      final tgVals = tgReadings.map((r) => r.glucose!.value).toList();
      stats = _tgStats(tgVals, estVals);
    }

    return TrendsVm(
      range: range,
      readingsSorted: filtered,
      tgReadings: tgReadings,
      stats: stats,
      estimatedBgValues: estVals,
    );
  }

  TgTrendStats _tgStats(List<double> tgVals, List<double>? estVals) {
    var tgMin = tgVals.first;
    var tgMax = tgVals.first;
    var tgSum = 0.0;
    for (final v in tgVals) {
      if (v < tgMin) tgMin = v;
      if (v > tgMax) tgMax = v;
      tgSum += v;
    }
    final tgAvg = tgSum / tgVals.length;

    double? eMin;
    double? eMax;
    double? eAvg;
    if (estVals != null && estVals.length == tgVals.length) {
      var lo = estVals.first;
      var hi = estVals.first;
      var eSum = 0.0;
      for (final v in estVals) {
        if (v < lo) lo = v;
        if (v > hi) hi = v;
        eSum += v;
      }
      eMin = lo;
      eMax = hi;
      eAvg = eSum / estVals.length;
    }

    return TgTrendStats(
      tgMin: tgMin,
      tgMax: tgMax,
      tgAvg: tgAvg,
      estMin: eMin,
      estMax: eMax,
      estAvg: eAvg,
    );
  }
}
