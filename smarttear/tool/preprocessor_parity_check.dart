import 'dart:convert';
import 'dart:io';

import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/infrastructure/ml/preprocessor.dart';
import 'package:smarttear/infrastructure/ml/scaler_params.dart';

List<double> _asDoubleList(Object? v) {
  final list = v as List<dynamic>? ?? const <dynamic>[];
  return list.map((e) => (e as num).toDouble()).toList(growable: false);
}

double _round6(double v) => double.parse(v.toStringAsFixed(6));

void main() {
  final file = File('assets/config/scaler_params.json');
  if (!file.existsSync()) {
    stderr.writeln('Missing assets/config/scaler_params.json');
    exit(1);
  }

  final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  final scaler = ScalerParams.fromJson(jsonMap);

  final packets = <Map<String, Object>>[
    {
      'label': 'Packet A — typical valid reading',
      'raw_channels': <double>[
        0.6234,
        0.5891,
        0.4102,
        0.5567,
        0.3341,
        0.5123,
        0.5034,
        0.0821,
      ],
      'contact_duration_ms': 1500,
    },
    {
      'label': 'Packet B — low glucose, short contact',
      'raw_channels': <double>[
        0.4100,
        0.5200,
        0.3100,
        0.4200,
        0.2100,
        0.4600,
        0.4900,
        0.0300,
      ],
      'contact_duration_ms': 600,
    },
    {
      'label': 'Packet C — high values, long contact',
      'raw_channels': <double>[
        0.8200,
        0.7400,
        0.5800,
        0.6800,
        0.4800,
        0.6400,
        0.5400,
        0.1300,
      ],
      'contact_duration_ms': 2800,
    },
  ];

  final pre = Preprocessor();

  print('=' * 60);
  print('DART PARITY CHECK — feature vector must match ml_training step2');
  print('=' * 60);

  for (final p in packets) {
    final label = p['label']! as String;
    final rawChannels = p['raw_channels']! as List<double>;
    final contactDurationMs = p['contact_duration_ms']! as int;

    final pkg = DataPackage(
      id: 'parity',
      deviceId: 'parity-device',
      timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      schemaVersion: 1,
      sampleStatus: 'complete',
      contactDurationMs: contactDurationMs,
      rawChannels: rawChannels,
    );

    final out = pre.preprocess(pkg, scaler);
    final features = out.features.map(_round6).toList(growable: false);

    print('\n$label');
    print('  raw_channels:        $rawChannels');
    print('  contact_duration_ms: $contactDurationMs');
    print('  feature_vector (9):  $features');
  }

  print('\n' + '=' * 60);
}

