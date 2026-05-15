/// Display / status bands for analytes (aligned with Park TG training distribution).
class AnalyteReferenceRanges {
  AnalyteReferenceRanges._();

  /// Tear glucose (mmol/L). Display band for glucose_model_v1 on stratified ch0.
  /// Wider than lab literature so typical on-device outputs are not all flagged HIGH.
  static const double tearGlucoseMinMmolL = 0.30;
  static const double tearGlucoseMaxMmolL = 0.85;

  static const double sodiumMin = 120.0;
  static const double sodiumMax = 165.0;
  static const double potassiumMin = 20.0;
  static const double potassiumMax = 42.0;
  static const double chlorideMin = 106.0;
  static const double chlorideMax = 136.0;

  static const double cholesterolMinMmolL = 0.5;
  static const double cholesterolMaxMmolL = 3.0;

  static String tearGlucoseRangeLabel() =>
      '${tearGlucoseMinMmolL.toStringAsFixed(1)} – ${tearGlucoseMaxMmolL.toStringAsFixed(2)}';

  static String cholesterolRangeLabel() =>
      '${cholesterolMinMmolL.toStringAsFixed(1)} – ${cholesterolMaxMmolL.toStringAsFixed(1)} mmol/L';
}
