import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/services/tg_bg_estimator_port.dart';
import 'tg_bg_scaler_params.dart';

/// ML-based TG→BG mapper (native TFLite).
class TgBgMlModel implements TgBgEstimatorPort {
  static const _modelPath = 'assets/models/tg_bg_model_v1.tflite';

  Interpreter? _interpreter;
  TgBgScalerParams? _scaler;
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> initialize() async {
    try {
      _scaler = await TgBgScalerParams.load();
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Estimated blood glucose in mmol/L.
  @override
  double? estimateBG(double tgMmol) {
    if (!_ready || _interpreter == null || _scaler == null) {
      return _fallbackEstimate(tgMmol);
    }

    try {
      final rawFeatures = [tgMmol, tgMmol * tgMmol, tgMmol * tgMmol * tgMmol];
      final normFeatures = _scaler!.normalize(rawFeatures);

      final input = <Float32List>[Float32List.fromList(normFeatures)];
      final output = <Float32List>[Float32List(1)];

      _interpreter!.run(input, output);
      return output[0][0].clamp(2.0, 33.0).toDouble();
    } catch (_) {
      return _fallbackEstimate(tgMmol);
    }
  }

  double _fallbackEstimate(double tgMmol) {
    const meanRatio = 15.9;
    return (tgMmol * meanRatio).clamp(2.0, 33.0);
  }

  void dispose() {
    _interpreter?.close();
    _ready = false;
  }
}
