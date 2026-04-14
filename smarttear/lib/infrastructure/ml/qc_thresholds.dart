import 'dart:convert';

import 'package:flutter/services.dart';

class QCThresholds {
  const QCThresholds({
    required this.minContactDurationMs,
    required this.minChannelVariance,
    required this.glucoseMin,
    required this.glucoseMax,
    required this.schemaVersion,
  });

  final int minContactDurationMs;
  final double minChannelVariance;
  final double glucoseMin;
  final double glucoseMax;
  final int schemaVersion;

  static Future<QCThresholds> load() async {
    final raw = await rootBundle.loadString('assets/config/qc_thresholds.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('qc_thresholds.json must be a JSON object');
    }

    return QCThresholds.fromJson(decoded);
  }

  factory QCThresholds.fromJson(Map json) {
    double asDouble(Object? v) => (v as num).toDouble();
    int asInt(Object? v) => (v as num).toInt();

    return QCThresholds(
      minContactDurationMs: asInt(json['min_contact_duration_ms']),
      minChannelVariance: asDouble(json['min_channel_variance']),
      glucoseMin: asDouble(json['glucose_min']),
      glucoseMax: asDouble(json['glucose_max']),
      schemaVersion: asInt(json['schema_version']),
    );
  }
}

