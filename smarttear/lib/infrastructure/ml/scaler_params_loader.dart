import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'scaler_params.dart';

class ScalerParamsLoader {
  ScalerParamsLoader._();

  static ScalerParams? _cached;

  static Future<ScalerParams> load() async {
    final existing = _cached;
    if (existing != null) return existing;

    try {
      final raw = await rootBundle.loadString('assets/config/scaler_params.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('scaler_params.json must be a JSON object');
      }

      final params = ScalerParams.fromJson(decoded);
      _cached = params;
      return params;
    } on FlutterError {
      // Asset missing.
      final params = ScalerParams.defaultParams();
      _cached = params;
      return params;
    }
  }
}

