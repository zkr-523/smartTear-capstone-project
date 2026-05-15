import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_web/tflite_web.dart';

import '../../domain/entities/analyte_value.dart';
import '../../domain/services/analyte_model_port.dart';
import 'inference_exception.dart';

/// On-device TFLite via TensorFlow.js + WASM (same .tflite assets as native).
class TfliteAnalyteModel implements AnalyteModelPort {
  static const _manifestAssetPath = 'assets/config/model_manifest.json';
  static const _modelDir = 'assets/models';

  Future<void>? _initFuture;
  TFLiteModel? _glucose;
  TFLiteModel? _electrolytes;
  TFLiteModel? _cholesterol;

  @override
  String get modelVersion =>
      'glucose:v1+electrolytes:v1+cholesterol:v1 (TFLite Web)';

  @override
  Future<List<AnalyteValue>> estimate(List<double> features) async {
    if (features.length != 9) {
      throw ArgumentError.value(
        features.length,
        'features.length',
        'features must have exactly 9 elements',
      );
    }

    await _ensureLoaded();

    final tg = await _run(_glucose!, features, 1);
    final elec = await _run(_electrolytes!, features, 3);
    final chol = await _run(_cholesterol!, features, 1);

    return <AnalyteValue>[
      AnalyteValue(analyteCode: 'TG', value: tg[0], unit: 'mmol/L'),
      AnalyteValue(analyteCode: 'Na', value: elec[0], unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'K', value: elec[1], unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'Cl', value: elec[2], unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'Chol', value: chol[0], unit: 'mmol/L'),
    ];
  }

  Future<List<double>> _run(
    TFLiteModel model,
    List<double> features,
    int outputCount,
  ) async {
    final input = createTensor(
      Float32List.fromList(features),
      shape: [1, features.length],
      type: TFLiteDataType.float32,
    );
    try {
      final raw = model.predict<Object>(input);
      final out = _outputTensor(raw, model);
      try {
        final data = await out.dataAsync<Float32List>();
        return List<double>.generate(
          outputCount,
          (i) => i < data.length ? data[i].toDouble() : 0.0,
        );
      } finally {
        out.dispose();
      }
    } finally {
      input.dispose();
    }
  }

  Tensor _outputTensor(Object raw, TFLiteModel model) {
    if (raw is Tensor) return raw;
    if (raw is List) {
      for (final item in raw) {
        if (item is Tensor) return item;
      }
    }
    if (raw is NamedTensorMap) {
      for (final info in model.outputs) {
        final t = raw[info.name];
        if (t is Tensor) return t;
      }
    }
    throw StateError('Unexpected TFLite output: ${raw.runtimeType}');
  }

  Future<void> _ensureLoaded() {
    final existing = _initFuture;
    if (existing != null) return existing;
    final f = _load();
    _initFuture = f;
    return f;
  }

  Future<void> _load() async {
    try {
      await TFLiteWeb.initialize();

      final raw = await rootBundle.loadString(_manifestAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('model_manifest.json must be a JSON object');
      }

      String modelFileFor(String key) {
        final v = decoded[key];
        if (v is! Map) {
          throw StateError('model_manifest.json missing "$key"');
        }
        final file = v['file'];
        if (file is! String || file.trim().isEmpty) {
          throw StateError('model_manifest.json "$key.file" missing');
        }
        return file;
      }

      _glucose = await _loadModel(modelFileFor('glucose'));
      _electrolytes = await _loadModel(modelFileFor('electrolytes'));
      _cholesterol = await _loadModel(modelFileFor('cholesterol'));
    } catch (e, st) {
      throw InferenceException(
        'Failed to load TFLite models on web — check assets/models/ and web/tflite/',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Future<TFLiteModel> _loadModel(String fileName) async {
    final data = await rootBundle.load('$_modelDir/$fileName');
    final bytes = data.buffer.asUint8List();
    return TFLiteModel.fromMemory(bytes);
  }
}
