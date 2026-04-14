# SmartTear — Step 4: Convert trained models to TFLite FP16
# Run after train_models.py
# Produces: 3 .tflite files + model_manifest.json

import tensorflow as tf
import json
import os

os.makedirs('tflite_output', exist_ok=True)

MODELS = [
    {
        'name':    'glucose',
        'source':  'saved_models/glucose_model.keras',
        'output':  'tflite_output/glucose_model_v1.tflite',
        'version': 'v1',
        'labels':  ['TG'],
        'units':   ['mmol/L'],
    },
    {
        'name':    'electrolytes',
        'source':  'saved_models/electrolytes_model.keras',
        'output':  'tflite_output/electrolytes_model_v1.tflite',
        'version': 'v1',
        'labels':  ['Na', 'K', 'Cl'],
        'units':   ['mEq/L', 'mEq/L', 'mEq/L'],
    },
    {
        'name':    'cholesterol',
        'source':  'saved_models/cholesterol_model.keras',
        'output':  'tflite_output/cholesterol_model_v1.tflite',
        'version': 'v1',
        'labels':  ['Chol'],
        'units':   ['mmol/L'],
    },
]

manifest = {}

for m in MODELS:
    print(f"Converting {m['name']}...")
    model = tf.keras.models.load_model(m['source'])

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]

    tflite_model = converter.convert()

    with open(m['output'], 'wb') as f:
        f.write(tflite_model)

    size_kb = os.path.getsize(m['output']) / 1024
    print(f"  Saved {m['output']}  ({size_kb:.1f} KB)")

    manifest[m['name']] = {
        'file':    os.path.basename(m['output']),
        'version': m['version'],
        'labels':  m['labels'],
        'units':   m['units'],
    }

with open('tflite_output/model_manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)

print("\nTFLite export complete. Files in tflite_output/")
print("\nNext — copy to Flutter:")
print("  copy tflite_output\\*.tflite ..\\smarttear\\assets\\models\\")
print("  copy tflite_output\\model_manifest.json ..\\smarttear\\assets\\config\\")
print("  copy scaler_params.json ..\\smarttear\\assets\\config\\")

