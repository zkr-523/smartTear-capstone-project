import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_web/tflite_web.dart';

import 'tg_bg_scaler_params.dart';

/// ML-based TG→BG mapper (TFLite Web / TensorFlow.js).
class TgBgMlModel {
  static const _modelPath = 'assets/models/tg_bg_model_v1.tflite';

  TFLiteModel? _model;
  TgBgScalerParams? _scaler;
  bool _ready = false;
  Future<void>? _initFuture;

  bool get isReady => _ready;

  Future<void> initialize() async {
    final existing = _initFuture;
    if (existing != null) return existing;
    final f = _load();
    _initFuture = f;
    return f;
  }

  Future<void> _load() async {
    try {
      await TFLiteWeb.initialize();
      _scaler = await TgBgScalerParams.load();
      final data = await rootBundle.load(_modelPath);
      _model = await TFLiteModel.fromMemory(data.buffer.asUint8List());
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  double? estimateBG(double tgMmol) {
    if (!_ready || _model == null || _scaler == null) {
      return _fallbackEstimate(tgMmol);
    }

    try {
      final rawFeatures = [tgMmol, tgMmol * tgMmol, tgMmol * tgMmol * tgMmol];
      final normFeatures = _scaler!.normalize(rawFeatures);

      final input = createTensor(
        Float32List.fromList(normFeatures),
        shape: [1, 3],
        type: TFLiteDataType.float32,
      );
      try {
        final raw = _model!.predict<Object>(input);
        final tensor = _outputTensor(raw);
        try {
          final data = tensor.dataSync<Float32List>();
          final bg = data.isNotEmpty ? data[0] : double.nan;
          return bg.isFinite ? bg.clamp(2.0, 33.0).toDouble() : _fallbackEstimate(tgMmol);
        } finally {
          tensor.dispose();
        }
      } finally {
        input.dispose();
      }
    } catch (_) {
      return _fallbackEstimate(tgMmol);
    }
  }

  Tensor _outputTensor(Object raw) {
    if (raw is Tensor) return raw;
    if (raw is List) {
      for (final item in raw) {
        if (item is Tensor) return item;
      }
    }
    if (raw is NamedTensorMap) {
      for (final info in _model!.outputs) {
        final t = raw[info.name];
        if (t is Tensor) return t;
      }
    }
    throw StateError('Unexpected TFLite output: ${raw.runtimeType}');
  }

  double _fallbackEstimate(double tgMmol) {
    const meanRatio = 15.9;
    return (tgMmol * meanRatio).clamp(2.0, 33.0);
  }

  void dispose() {
    _model = null;
    _ready = false;
  }
}
