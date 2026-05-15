class ScalerParams {
  const ScalerParams({
    required this.featureMin,
    required this.featureMax,
    required this.clipMin,
    required this.clipMax,
    this.contactDurationMinMs = 500,
    this.contactDurationMaxMs = 2500,
  });

  /// Must contain exactly 8 elements.
  final List<double> featureMin;

  /// Must contain exactly 8 elements.
  final List<double> featureMax;

  /// Must contain exactly 8 elements.
  final List<double> clipMin;

  /// Must contain exactly 8 elements.
  final List<double> clipMax;

  /// Matches ml_training step2_preprocess contact_normalize (500–2500 ms).
  final int contactDurationMinMs;
  final int contactDurationMaxMs;

  factory ScalerParams.fromJson(Map json) {
    List<double> asDoubleList(Object? v) {
      final list = v as List<dynamic>? ?? const <dynamic>[];
      return list.map((e) => (e as num).toDouble()).toList(growable: false);
    }

    var contactMinMs = 500;
    var contactMaxMs = 2500;
    final contactNorm = json['contactDurationNorm'];
    if (contactNorm is Map) {
      final minV = contactNorm['min_ms'];
      final maxV = contactNorm['max_ms'];
      if (minV is num) contactMinMs = minV.toInt();
      if (maxV is num) contactMaxMs = maxV.toInt();
    }

    return ScalerParams(
      featureMin: asDoubleList(json['featureMin']),
      featureMax: asDoubleList(json['featureMax']),
      clipMin: asDoubleList(json['clipMin']),
      clipMax: asDoubleList(json['clipMax']),
      contactDurationMinMs: contactMinMs,
      contactDurationMaxMs: contactMaxMs,
    );
  }

  factory ScalerParams.defaultParams() {
    return ScalerParams(
      featureMin: List<double>.filled(8, 0.0, growable: false),
      featureMax: List<double>.filled(8, 1.0, growable: false),
      clipMin: List<double>.filled(8, 0.0, growable: false),
      clipMax: List<double>.filled(8, 1.0, growable: false),
    );
  }
}

