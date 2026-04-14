import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';
import '../../domain/services/analyte_model_port.dart';
import '../../infrastructure/ml/data_ingestor.dart';
import '../../infrastructure/ml/package_validator.dart';
import '../../infrastructure/ml/preprocessor.dart';
import '../../infrastructure/ml/qc_classifier.dart';
import '../../infrastructure/ml/qc_thresholds.dart';
import '../../infrastructure/ml/scaler_params_loader.dart';
import '../providers/simulation_connector_provider.dart';

class HomeAcquireException implements Exception {
  const HomeAcquireException(this.message, {required this.isRetryable});
  final String message;
  final bool isRetryable;

  @override
  String toString() => message;
}

class _FakeAnalyteModel implements AnalyteModelPort {
  _FakeAnalyteModel();

  final _rand = Random();

  @override
  String get modelVersion => 'fake-model-0';

  @override
  Future<List<AnalyteValue>> estimate(List<double> features) async {
    // Deterministic-ish preview: map mean feature to a plausible TG value.
    final mean = features.isEmpty ? 0.5 : features.reduce((a, b) => a + b) / features.length;
    final noise = (_rand.nextDouble() - 0.5) * 8.0;
    final tg = (80.0 + mean * 60.0 + noise).clamp(40.0, 240.0);

    return <AnalyteValue>[
      AnalyteValue(analyteCode: 'TG', value: tg.toDouble(), unit: 'mg/dL'),
    ];
  }
}

class InMemoryReadingRepository implements ReadingRepositoryPort {
  InMemoryReadingRepository(this._ref);

  final Ref _ref;
  int _nextId = 1;

  @override
  Future<String> saveRawPackage(package) async {
    // Stable-ish reference. In real impl, persist raw package.
    return 'raw_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<int> saveReading(Reading reading) async {
    final id = reading.id ?? _nextId++;
    final stored = reading.copyWith(id: id);
    _ref.read(readingsStoreProvider.notifier).upsert(stored);
    return id;
  }
}

class ReadingsStore extends StateNotifier<List<Reading>> {
  ReadingsStore() : super(const <Reading>[]);

  void upsert(Reading reading) {
    final i = state.indexWhere((r) => r.id == reading.id);
    if (i == -1) {
      state = <Reading>[reading, ...state];
    } else {
      final next = [...state];
      next[i] = reading;
      state = next;
    }
  }
}

final readingsStoreProvider = StateNotifierProvider<ReadingsStore, List<Reading>>(
  (ref) => ReadingsStore(),
);

final readingRepositoryProvider = Provider<ReadingRepositoryPort>(
  (ref) => InMemoryReadingRepository(ref),
);

/// Builds a fresh ingestor so [QCThresholds.load] always reflects current assets.
Future<DataIngestor> _buildIngestor(Ref ref) async {
  final thresholds = await QCThresholds.load();
  final scaler = await ScalerParamsLoader.load();
  return DataIngestor(
    validator: const PackageValidator(),
    preprocessor: const Preprocessor(),
    modelPort: _FakeAnalyteModel(),
    qcClassifier: const QCClassifier(),
    thresholds: thresholds,
    scaler: scaler,
    repository: ref.read(readingRepositoryProvider),
  );
}

class HomeViewModel extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async => null;

  Future<void> acquireReading() async {
    state = const AsyncLoading();

    try {
      final connector = ref.read(simulationConnectorProvider.notifier);
      final ingestor = await _buildIngestor(ref);

      final pkg = await connector.triggerReadingAndWait();

      // No user auth yet; use a temporary user id.
      const userId = 'demo';

      final result = await ingestor.ingest(pkg, userId);
      if (result is IngestFailure) {
        throw HomeAcquireException(result.reason, isRetryable: result.isRetryable);
      }

      final reading = (result as IngestSuccess).reading;
      final id = reading.id;
      if (id == null) {
        throw const HomeAcquireException('Could not determine reading id', isRetryable: true);
      }

      state = AsyncData(id);
    } on TimeoutException catch (_, st) {
      state = AsyncError(
        const HomeAcquireException(
          'Timed out waiting for the device reading. Check the simulation server and try again.',
          isRetryable: true,
        ),
        st,
      );
    } catch (e, st) {
      if (e is HomeAcquireException) {
        state = AsyncError(e, st);
      } else {
        state = AsyncError(
          HomeAcquireException('Unexpected error: $e', isRetryable: true),
          st,
        );
      }
    }
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, int?>(
  HomeViewModel.new,
);

