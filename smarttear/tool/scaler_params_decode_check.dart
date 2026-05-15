import 'dart:convert';
import 'dart:io';

import 'package:smarttear/infrastructure/ml/scaler_params.dart';

void main() {
  final m = jsonDecode(
    File('assets/config/scaler_params.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final s = ScalerParams.fromJson(m);
  print(
    '${s.featureMin.length},${s.featureMax.length},${s.clipMin.length},${s.clipMax.length} '
    'contact=${s.contactDurationMinMs}-${s.contactDurationMaxMs}ms',
  );
}

