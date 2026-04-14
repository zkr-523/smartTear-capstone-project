import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';
import '../../domain/services/analyte_model_port.dart';
import 'package_validator.dart';
import 'preprocessor.dart';
import 'qc_classifier.dart';
import 'qc_thresholds.dart';
import 'scaler_params.dart';

sealed class IngestResult {
  const IngestResult();
}

final class IngestSuccess extends IngestResult {
  const IngestSuccess(this.reading);
  final Reading reading;
}

final class IngestFailure extends IngestResult {
  const IngestFailure(this.reason, this.isRetryable);
  final String reason;
  final bool isRetryable;
}

class DataIngestor {
  const DataIngestor({
    required this.validator,
    required this.preprocessor,
    required this.modelPort,
    required this.qcClassifier,
    required this.thresholds,
    required this.scaler,
    required this.repository,
  });

  final PackageValidator validator;
  final Preprocessor preprocessor;
  final AnalyteModelPort modelPort;
  final QCClassifier qcClassifier;
  final QCThresholds thresholds;
  final ScalerParams scaler;
  final ReadingRepositoryPort repository;

  Future<IngestResult> ingest(DataPackage package, String userId) async {
    try {
      // 1. Validate packet
      final validation = validator.validate(package, thresholds);
      if (validation is ValidationFailure) {
        return IngestFailure(validation.reason, false);
      }

      // 2. Write-ahead raw package (prevent data loss)
      final String rawPackageRef;
      try {
        rawPackageRef = await repository.saveRawPackage(package);
      } catch (_) {
        return const IngestFailure('Storage error — tap Retry', true);
      }

      // 3. Preprocess features
      final features = preprocessor.preprocess(package, scaler);

      // 4. Run model
      final analytes = await () async {
        try {
          return await modelPort.estimate(features.features);
        } catch (_) {
          return null;
        }
      }();
      if (analytes == null) {
        return const IngestFailure('Processing error — tap Retry', true);
      }

      // 5. QC classify
      final qc = qcClassifier.classify(package, analytes, thresholds);

      // 6. Build Reading object
      final reading = Reading(
        id: null,
        userId: userId,
        deviceId: package.deviceId,
        takenAt: package.timestamp,
        sampleStatus: package.sampleStatus,
        contactDurationMs: package.contactDurationMs,
        qcStatus: qc.status,
        invalidReason: qc.reason,
        modelVersion: modelPort.modelVersion,
        rawPackageRef: rawPackageRef,
        analytes: analytes,
        note: null,
      );

      // 7. Persist reading
      try {
        await repository.saveReading(reading);
      } catch (_) {
        return const IngestFailure('Storage error — tap Retry', true);
      }

      // 8. Return success
      return IngestSuccess(reading);
    } catch (_) {
      // Never throw exceptions out of this method.
      return const IngestFailure('Processing error — tap Retry', true);
    }
  }
}

