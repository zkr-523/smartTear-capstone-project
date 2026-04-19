import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/ml/data_ingestor.dart';
import '../../infrastructure/ml/package_validator.dart';
import '../../infrastructure/ml/preprocessor.dart';
import '../../infrastructure/ml/qc_classifier.dart';
import '../../infrastructure/ml/qc_thresholds.dart';
import '../../infrastructure/ml/scaler_params_loader.dart';
import '../../infrastructure/ml/analyte_model_impl.dart';
import '../../infrastructure/repositories/local_reading_repository.dart';

final readingRepositoryProvider = Provider<LocalReadingRepository>((ref) {
  return LocalReadingRepository();
});

final dataIngestorProvider = FutureProvider<DataIngestor>((ref) async {
  final thresholds = await QCThresholds.load();
  final scaler = await ScalerParamsLoader.load();
  final repository = ref.watch(readingRepositoryProvider);

  return DataIngestor(
    validator: const PackageValidator(),
    preprocessor: const Preprocessor(),
    modelPort: TfliteAnalyteModel(),
    qcClassifier: const QCClassifier(),
    thresholds: thresholds,
    scaler: scaler,
    repository: repository,
  );
});

