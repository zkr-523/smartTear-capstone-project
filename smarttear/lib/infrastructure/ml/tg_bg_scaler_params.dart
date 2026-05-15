import 'dart:convert';

import 'package:flutter/services.dart';

class TgBgScalerParams {
  final List<double> featureMin;
  final List<double> featureMax;

  const TgBgScalerParams({
    required this.featureMin,
    required this.featureMax,
  });

  factory TgBgScalerParams.fromJson(Map<String, dynamic> json) {
    return TgBgScalerParams(
      featureMin: List<double>.from(
        (json['feature_min'] as List).map((e) => (e as num).toDouble()),
      ),
      featureMax: List<double>.from(
        (json['feature_max'] as List).map((e) => (e as num).toDouble()),
      ),
    );
  }

  static Future<TgBgScalerParams> load() async {
    final raw = await rootBundle.loadString('assets/config/scaler_tg_bg.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return TgBgScalerParams.fromJson(json);
  }

  /// Normalize [TG_mM, TG_mM², TG_mM³] to [0, 1].
  List<double> normalize(List<double> rawFeatures) {
    final result = <double>[];
    for (var i = 0; i < rawFeatures.length; i++) {
      final mn = featureMin[i];
      final mx = featureMax[i];
      final range = mx - mn;
      if (range <= 0) {
        result.add(0.0);
      } else {
        result.add(((rawFeatures[i] - mn) / range).clamp(0.0, 1.0));
      }
    }
    return result;
  }
}
