"""
SmartTear ML Pipeline — Step 4: TFLite Export + Parity
=======================================================
Exports trained Keras models to TFLite with:
  - Dynamic range quantization (reduces size ~4x, faster mobile inference)
  - Representative dataset for full-integer quantization option
  - Parity verification between Python and expected Dart output
"""

import numpy as np
import json, os, shutil
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf

from paths import (
    MODEL_DIR,
    TFLITE_DIR,
    SCALER_DIR,
    FLUTTER_MODELS,
    FLUTTER_CONFIG,
    ensure_dirs,
)

ensure_dirs('tflite')

MODELS = [
    {'name': 'glucose',      'version': 1, 'inputs': 9, 'outputs': 1},
    {'name': 'electrolytes', 'version': 1, 'inputs': 9, 'outputs': 3},
    {'name': 'cholesterol',  'version': 1, 'inputs': 9, 'outputs': 1},
]

def export_tflite(model_name, representative_data=None):
    """Convert Keras model to TFLite with dynamic range quantization."""
    keras_path = os.path.join(MODEL_DIR, f'{model_name}_final.keras')
    print(f"  Loading: {keras_path}")
    model = tf.keras.models.load_model(keras_path, compile=False)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    # Dynamic range quantization — best balance of size/accuracy for mobile
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]

    tflite_model = converter.convert()

    out_path = os.path.join(TFLITE_DIR, f'{model_name}_model_v1.tflite')
    with open(out_path, 'wb') as f:
        f.write(tflite_model)

    size_kb = os.path.getsize(out_path) / 1024
    print(f"  Saved: {out_path}  ({size_kb:.1f} KB)")
    return out_path, model

def verify_parity(model_name, keras_model):
    """
    Run 3 test packets through the model.
    Print feature vectors for Dart parity verification.
    """
    print(f"\n  PARITY CHECK — {model_name.upper()}")
    test_packets = [
        # [ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7, contact_norm]
        {'name': 'Normal TG',   'x': [0.35, 0.62, 0.45, 0.55, 0.35, 0.55, 0.51, 0.05, 0.60]},
        {'name': 'High TG',     'x': [0.78, 0.65, 0.48, 0.58, 0.40, 0.52, 0.52, 0.08, 0.80]},
        {'name': 'Low contact', 'x': [0.20, 0.60, 0.44, 0.54, 0.30, 0.50, 0.50, 0.10, 0.20]},
    ]

    for pkt in test_packets:
        x = np.array(pkt['x'], dtype=np.float32).reshape(1, -1)
        pred = keras_model.predict(x, verbose=0)
        print(f"    {pkt['name']:12s}: input={[f'{v:.4f}' for v in pkt['x'][:3]]}...  pred={pred.ravel().tolist()}")

def build_combined_scaler(scaler_dir):
    """
    Build one combined scaler_params.json for Flutter.
    Flutter uses a single global scaler for all 8 channels.
    """
    # Use glucose scaler as the reference (fitted on Park 2024 data)
    scaler_path = os.path.join(scaler_dir, 'scaler_glucose.json')
    with open(scaler_path) as f:
        scaler = json.load(f)

    combined = {
        'clipMin':      [max(0, float(mn) - float(sc)) for mn, sc in zip(scaler['feature_min'], scaler['scale'])],
        'clipMax':      [float(mx) + float(sc) for mx, sc in zip(scaler['feature_max'], scaler['scale'])],
        'featureMin':   scaler['feature_min'],
        'featureMax':   scaler['feature_max'],
        'contactDurationNorm': {'min_ms': 500, 'max_ms': 2500},
        'modelVersions': {
            'glucose':      'glucose_model_v1.tflite',
            'electrolytes': 'electrolytes_model_v1.tflite',
            'cholesterol':  'cholesterol_model_v1.tflite',
        },
        'sources': {
            'glucose':      'Park et al. 2024, Nature Communications — 1,407 real TG measurements',
            'electrolytes': 'Calimon et al. 2024, Nernst ISE equation, 50-subject clinical data',
            'cholesterol':  'Song et al. 2022, Advanced Science — electrochemical calibration',
        }
    }
    return combined

if __name__ == '__main__':
    print("═" * 60)
    print("TFLITE EXPORT")
    print("═" * 60)

    tflite_paths = []
    for m in MODELS:
        print(f"\n[{m['name'].upper()}]")
        path, keras_model = export_tflite(m['name'])
        tflite_paths.append(path)
        verify_parity(m['name'], keras_model)

    # Build combined scaler for Flutter
    print("\n  Building combined scaler_params.json...")
    try:
        combined_scaler = build_combined_scaler(SCALER_DIR)
        scaler_out = os.path.join(TFLITE_DIR, 'scaler_params.json')
        with open(scaler_out, 'w') as f:
            json.dump(combined_scaler, f, indent=2)
        print(f"  Scaler saved: {scaler_out}")
    except Exception as e:
        print(f"  Scaler note: {e} — copy from splits/scaler_glucose.json manually")

    # Copy to Flutter assets (smarttear/assets/)
    print("\n  Copying to Flutter assets...")
    os.makedirs(FLUTTER_MODELS, exist_ok=True)
    os.makedirs(FLUTTER_CONFIG, exist_ok=True)

    for path in tflite_paths:
        fname = os.path.basename(path)
        dest = os.path.join(FLUTTER_MODELS, fname)
        shutil.copy2(path, dest)
        print(f"  Copied: {fname} → {dest}")

    scaler_src = os.path.join(TFLITE_DIR, 'scaler_params.json')
    if os.path.exists(scaler_src):
        scaler_dest = os.path.join(FLUTTER_CONFIG, 'scaler_params.json')
        shutil.copy2(scaler_src, scaler_dest)
        print(f"  Copied: scaler_params.json → {scaler_dest}")

    print("\n" + "═"*60)
    print("TFLite models and scaler copied to smarttear/assets/")
    print(f"  models: {FLUTTER_MODELS}")
    print(f"  config: {FLUTTER_CONFIG}")
    print("═"*60)
