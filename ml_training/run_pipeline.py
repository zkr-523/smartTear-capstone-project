"""
SmartTear ML Pipeline — Master Runner
======================================
Runs all 5 steps in sequence.
Execute: python run_pipeline.py
"""

import subprocess, sys, os, time

from paths import BASE_DIR, DATASET_DIR, SPLIT_DIR, SCALER_DIR, MODEL_DIR, TFLITE_DIR, REPORT_DIR

STEPS = [
    ('step1_generate_dataset.py', 'Data Generation from certified sources'),
    ('step2_preprocess.py',       'Advanced Preprocessing + Train/Val/Test Split'),
    ('step3_train.py',            'Model Training with 5-Fold CV + Early Stopping'),
    ('step4_export_tflite.py',    'TFLite Export with Quantization'),
    ('step5_evaluate.py',         'Comprehensive Evaluation + Parkes Grid'),
]

print("=" * 65)
print("SmartTear ML Pipeline — Full Run")
print("=" * 65)

total_start = time.time()
for script, description in STEPS:
    print(f"\n{'─'*65}")
    print(f"STEP: {description}")
    print(f"{'─'*65}")
    t0 = time.time()
    result = subprocess.run(
        [sys.executable, os.path.join(BASE_DIR, script)],
        cwd=BASE_DIR,
        capture_output=False)
    elapsed = time.time() - t0
    if result.returncode != 0:
        print(f"\n❌ FAILED: {script}")
        sys.exit(1)
    print(f"\n✓ Done in {elapsed:.1f}s")

total = time.time() - total_start
print(f"\n{'='*65}")
print(f"PIPELINE COMPLETE in {total:.1f}s")
print(f"Results in: {BASE_DIR}")
print(f"  datasets/  → {DATASET_DIR}")
print(f"  splits/    → {SPLIT_DIR}")
print(f"  scalers/   → {SCALER_DIR}")
print(f"  models/    → {MODEL_DIR}")
print(f"  tflite/    → {TFLITE_DIR}")
print(f"  reports/   → {REPORT_DIR}")
print(f"{'='*65}")
print()
print("Step 4 copies TFLite + scaler_params.json to smarttear/assets/ automatically.")
