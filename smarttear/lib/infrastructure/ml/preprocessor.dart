import '../../domain/entities/data_package.dart';
import 'scaler_params.dart';

class PreprocessedFeatures {
  const PreprocessedFeatures({
    required this.features,
    required this.contactDurationAvailable,
  });

  /// 9 elements: 8 normalized channels + contactDuration feature.
  final List<double> features;
  final bool contactDurationAvailable;
}

class Preprocessor {
  const Preprocessor();

  PreprocessedFeatures preprocess(DataPackage package, ScalerParams scaler) {
    final channels = package.rawChannels;
    final clipped = List<double>.filled(8, 0.0, growable: false);

    for (var i = 0; i < 8 && i < channels.length; i++) {
      final v = channels[i];
      clipped[i] = _clamp(v, scaler.clipMin[i], scaler.clipMax[i]);
    }

    final norm = List<double>.filled(8, 0.0, growable: false);
    for (var i = 0; i < 8; i++) {
      final denom = (scaler.featureMax[i] - scaler.featureMin[i]);
      final raw = denom == 0.0
          ? 0.0
          : (clipped[i] - scaler.featureMin[i]) / denom;
      norm[i] = _clamp(raw, 0.0, 1.0);
    }

    final contactDurationMs = package.contactDurationMs;
    late final double contactFeature;
    late final bool contactDurationAvailable;

    if (contactDurationMs != null) {
      contactFeature = _clamp(contactDurationMs / 3000.0, 0.0, 1.0);
      contactDurationAvailable = true;
    } else {
      contactFeature = 0.0;
      contactDurationAvailable = false;
    }

    final features = <double>[
      ...norm,
      contactFeature,
    ];

    return PreprocessedFeatures(
      features: features,
      contactDurationAvailable: contactDurationAvailable,
    );
  }
}

double _clamp(double v, double min, double max) {
  if (v < min) return min;
  if (v > max) return max;
  return v;
}

