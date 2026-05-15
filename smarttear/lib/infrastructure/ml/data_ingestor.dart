import 'package:collection/collection.dart';

import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';
import '../../domain/services/analyte_model_port.dart';
import 'package_validator.dart';
import 'preprocessor.dart';
import 'qc_classifier.dart';
import 'qc_thresholds.dart';
import 'scaler_params.dart';
import 'tg_bg_ml_model.dart';

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
  DataIngestor({
    required this.validator,
    required this.preprocessor,
    required this.modelPort,
    required this.qcClassifier,
    required this.thresholds,
    required this.scaler,
    required this.repository,
    required this.tgBgModel,
  });

  final PackageValidator validator;
  final Preprocessor preprocessor;
  final AnalyteModelPort modelPort;
  final QCClassifier qcClassifier;
  final QCThresholds thresholds;
  final ScalerParams scaler;
  final ReadingRepositoryPort repository;
  final TgBgMlModel tgBgModel;

  Future<IngestResult> ingest(
    DataPackage package,
    String userId, {
    bool estBgEnabled = false,
  }) async {
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
      } catch (e) {
        return IngestFailure('Could not save raw package: $e', true);
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

      final enrichedAnalytes = _attachEstimatedBg(analytes, estBgEnabled);

      // 5. QC classify
      final qc = qcClassifier.classify(package, enrichedAnalytes, thresholds);

      // 6. Build Reading object
      final reading = Reading(
        id: null,
        userId: userId,
        deviceId: package.deviceId,
        // Wall-clock when processing completes on device (matches user expectation vs. simulator clock skew).
        takenAt: DateTime.now(),
        sampleStatus: package.sampleStatus,
        contactDurationMs: package.contactDurationMs,
        qcStatus: qc.status,
        invalidReason: qc.reason,
        modelVersion: modelPort.modelVersion,
        rawPackageRef: rawPackageRef,
        analytes: enrichedAnalytes,
        note: null,
      );

      // 7. Persist reading
      try {
        await repository.saveReading(reading);
      } catch (e) {
        return IngestFailure('Could not save reading: $e', true);
      }

      // 8. Return success
      return IngestSuccess(reading);
    } catch (e) {
      // Never throw exceptions out of this method.
      return IngestFailure('Processing error: $e', true);
    }
  }

  List<AnalyteValue> _attachEstimatedBg(
    List<AnalyteValue> analytes,
    bool estBgEnabled,
  ) {
    if (!estBgEnabled) return analytes;

    final tg = analytes.firstWhereOrNull((a) => a.analyteCode == 'TG');
    if (tg == null) return analytes;

    final bgMmol = tgBgModel.estimateBG(tg.value);
    if (bgMmol == null) return analytes;

    return analytes
        .map(
          (a) => a.analyteCode == 'TG'
              ? a.copyWith(estimatedBG: bgMmol)
              : a,
        )
        .toList();
  }
}

