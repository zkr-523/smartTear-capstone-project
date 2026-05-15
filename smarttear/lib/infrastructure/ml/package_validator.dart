import '../../domain/entities/data_package.dart';
import 'qc_thresholds.dart';

sealed class ValidationResult {
  const ValidationResult();
}

final class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

final class ValidationFailure extends ValidationResult {
  const ValidationFailure(this.reason);
  final String reason;
}

class PackageValidator {
  const PackageValidator();

  ValidationResult validate(DataPackage package, QCThresholds thresholds) {
    if (package.rawChannels.length != 8) {
      return const ValidationFailure('Corrupt packet: expected 8 channels');
    }

    if (package.sampleStatus == 'failed') {
      return const ValidationFailure('Device reported sample failure');
    }

    final outOfRange = package.rawChannels
        .any((v) => v < -0.1 || v > 1.1);
    if (outOfRange) {
      return const ValidationFailure(
        'Corrupt packet: channel value out of range',
      );
    }

    if (package.deviceId.isEmpty) {
      return const ValidationFailure('Missing device ID');
    }

    if (package.schemaVersion != thresholds.schemaVersion) {
      return const ValidationFailure('Schema version mismatch');
    }

    return const ValidationSuccess();
  }
}

