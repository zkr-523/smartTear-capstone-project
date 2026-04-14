import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/analyte_value.dart';
import '../../domain/services/analyte_model_port.dart';

class InferenceException implements Exception {
  InferenceException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

class TfliteAnalyteModel implements AnalyteModelPort {
  static const _manifestAssetPath = 'assets/config/model_manifest.json';

  static const _modelDir = 'assets/models';

  Future<void>? _initFuture;

  Interpreter? _glucose;
  Interpreter? _electrolytes;
  Interpreter? _cholesterol;

  @override
  String get modelVersion => 'glucose:v1+electrolytes:v1+cholesterol:v1';

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

    final glucose = _glucose!;
    final electrolytes = _electrolytes!;
    final cholesterol = _cholesterol!;

    final input = <Float32List>[Float32List.fromList(features)];

    final outGlucose = <Float32List>[Float32List(1)];
    glucose.run(input, outGlucose);
    final tg = outGlucose[0][0].toDouble();

    final outElec = <Float32List>[Float32List(3)];
    electrolytes.run(input, outElec);
    final na = outElec[0][0].toDouble();
    final k = outElec[0][1].toDouble();
    final cl = outElec[0][2].toDouble();

    final outChol = <Float32List>[Float32List(1)];
    cholesterol.run(input, outChol);
    final chol = outChol[0][0].toDouble();

    return <AnalyteValue>[
      AnalyteValue(analyteCode: 'TG', value: tg, unit: 'mmol/L'),
      AnalyteValue(analyteCode: 'Na', value: na, unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'K', value: k, unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'Cl', value: cl, unit: 'mEq/L'),
      AnalyteValue(analyteCode: 'Chol', value: chol, unit: 'mmol/L'),
    ];
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

      final glucoseFile = modelFileFor('glucose');
      final electrolytesFile = modelFileFor('electrolytes');
      final cholesterolFile = modelFileFor('cholesterol');

      final options = InterpreterOptions()..threads = 2;

      _glucose = await Interpreter.fromAsset('$_modelDir/$glucoseFile', options: options);
      _electrolytes =
          await Interpreter.fromAsset('$_modelDir/$electrolytesFile', options: options);
      _cholesterol =
          await Interpreter.fromAsset('$_modelDir/$cholesterolFile', options: options);
    } catch (e, st) {
      throw InferenceException(
        'Failed to load ML model — check assets/models/',
        cause: e,
        stackTrace: st,
      );
    }
  }
}

