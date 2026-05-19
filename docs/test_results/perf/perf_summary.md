# Performance run summary

Toolchain: Flutter 3.41.9, Dart 3.11.5, Python 3.14.0

## Ingest pipeline (1000 iterations, 100 warmup, 900 counted)

End-to-end latency (ms):

- min: 0.0510
- p50: 0.0660
- p95: 0.1260
- p99: 0.1920
- max: 0.6890
- mean: 0.0726

Per-stage latency (ms, p50 / p95):

- validate: 0.0000 / 0.0000
- preprocess: 0.0000 / 0.0000
- model.estimate (fake): 0.0080 / 0.0130
- qc.classify: 0.0020 / 0.0050

## Endpoint latency (500 iterations each, 50 warmup)

| Endpoint | p50 (ms) | p95 (ms) | max (ms) | mean (ms) |
| --- | --- | --- | --- | --- |
| GET /reading | 3.0852 | 3.4717 | 40.2024 | 3.2489 |
| GET /status | 2.8973 | 3.2665 | 18.9339 | 2.9546 |
| POST /pair | 2.9783 | 3.4466 | 11.1685 | 3.0288 |
| POST /chat (no API key) | 2.4368 | 3.0201 | 4.3237 | 2.4977 |

## DB growth (100 readings, 5 analytes each)

- baseline_bytes: 61440
- after_100_bytes: 86016
- delta_bytes: 24576
- delta_kb: 24.00
- delta_per_reading_bytes: 245.76

## APK size

- apk_path: build/app/outputs/flutter-apk/app-release.apk
- size_bytes: 88791239
- size_mb: 84.68

## Files created

- smarttear/test/perf/_fakes.dart
- smarttear/test/perf/ingest_pipeline_bench.dart
- smarttear/test/perf/db_growth_bench.dart
- simulation_server/perf/endpoint_latency.py
- docs/test_results/perf/ingest_pipeline_bench.txt
- docs/test_results/perf/db_growth_bench.txt
- docs/test_results/perf/endpoint_latency.txt
- docs/test_results/perf/apk_size.txt
- docs/test_results/perf/perf_summary.md
