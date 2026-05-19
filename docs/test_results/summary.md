# Test Run Summary

Run date: 2026-05-17
Toolchain: Flutter (Windows), Python 3.14.0, pytest 9.0.3

## Counts

| Suite | Planned | Passed | Failed | Skipped |
|---|---|---|---|---|
| Flutter (`smarttear/test/`) | 55 | 55 | 0 | 0 |
| Python (`simulation_server/tests/`) | 13 | 13 | 0 | 0 |
| **Total** | **68** | **68** | **0** | **0** |

Flutter breakdown (by ID prefix):
- CHAT-001..004 (existing): 4 passed
- CHAT-005..011 (new): 7 passed
- ING-001..010 (new): 10 passed
- BGR-001..005 (new): 5 passed
- VAL-001..005 (existing): 5 passed
- PRE-001..014 (new): 14 passed
- QC-001..009 (new): 9 passed
- widget_test (existing): 1 passed

Python breakdown: SIM-001..013, 13 passed.

## Defects uncovered / changes required to make tests run

1. **`tflite_flutter ^0.10.4` references removed `UnmodifiableUint8ListView`** — blocked compilation on current Dart SDK. Bumped `smarttear/pubspec.yaml` to `tflite_flutter: ^0.11.0`. `flutter pub get` resolved cleanly.
2. **`CardTheme` in `design_system.dart:244`** — Flutter 3.27+ expects `CardThemeData` for `ThemeData.cardTheme`. Changed `CardTheme(` → `CardThemeData(` (constructor args identical).
3. **`DataIngestor` and `EstimatedBgResolver` depended on the concrete `TgBgMlModel`**, which transitively imports `tflite_flutter` — would have forced ML-platform code into unit tests. Introduced one-method port `TgBgEstimatorPort` at `lib/domain/services/tg_bg_estimator_port.dart`; updated the two field declarations and made `TgBgMlModel` (native + web) `implements TgBgEstimatorPort`. Behavior unchanged.

## Tests that could not be written

None. All 39 new Dart cases and 13 Python cases were authored and pass.

## `widget_test.dart` final state

Pass. After the two compile fixes above, the existing boot/router smoke test runs and passes without modification to the test file.

## Artifacts in this directory

- `flutter_test_output.txt` — full `flutter test --reporter expanded` console capture.
- `pytest_output.txt` — full `pytest -v` console capture.
- `evaluation_report_copy.json` — verbatim copy of `ml_training/reports/evaluation_report.json`.
- `summary.md` — this file.
