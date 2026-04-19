import '../../domain/entities/analyte_value.dart';
import '../../domain/services/analyte_model_port.dart';

/// Web fallback: `tflite_flutter` relies on `dart:ffi` and does not compile on web.
///
/// This implementation returns deterministic placeholder values so the app can
/// run in Chrome for UI/demo purposes.
class TfliteAnalyteModel implements AnalyteModelPort {
  @override
  String get modelVersion => 'web-stub:v1';

  @override
  Future<List<AnalyteValue>> estimate(List<double> features) async {
    // Basic, stable pseudo-values derived from inputs.
    final base = (features.isEmpty ? 0.0 : features.first) * 10.0;
    final tg = (5.5 + base).clamp(2.5, 20.0);

    return <AnalyteValue>[
      AnalyteValue(
        analyteCode: 'TG',
        value: tg.toDouble(),
        unit: 'mmol/L',
        estimatedBG: tg.toDouble() * 18.0,
      ),
      const AnalyteValue(analyteCode: 'Na', value: 140, unit: 'mEq/L'),
      const AnalyteValue(analyteCode: 'K', value: 4.2, unit: 'mEq/L'),
      const AnalyteValue(analyteCode: 'Cl', value: 102, unit: 'mEq/L'),
      const AnalyteValue(analyteCode: 'Chol', value: 4.6, unit: 'mmol/L'),
    ];
  }
}

