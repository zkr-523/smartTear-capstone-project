class ScalerParams {
  const ScalerParams({
    required this.featureMin,
    required this.featureMax,
    required this.clipMin,
    required this.clipMax,
  });

  /// Must contain exactly 8 elements.
  final List<double> featureMin;

  /// Must contain exactly 8 elements.
  final List<double> featureMax;

  /// Must contain exactly 8 elements.
  final List<double> clipMin;

  /// Must contain exactly 8 elements.
  final List<double> clipMax;

  factory ScalerParams.fromJson(Map json) {
    List<double> asDoubleList(Object? v) {
      final list = v as List<dynamic>? ?? const <dynamic>[];
      return list.map((e) => (e as num).toDouble()).toList(growable: false);
    }

    return ScalerParams(
      featureMin: asDoubleList(json['feature_min']),
      featureMax: asDoubleList(json['feature_max']),
      clipMin: asDoubleList(json['clip_min']),
      clipMax: asDoubleList(json['clip_max']),
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

