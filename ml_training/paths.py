"""
Shared paths for the SmartTear ML pipeline.
All paths resolve relative to the ml_training/ directory (this file's parent).
"""

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DATASET_DIR = os.path.join(BASE_DIR, 'datasets')
SPLIT_DIR = os.path.join(BASE_DIR, 'splits')
SCALER_DIR = os.path.join(BASE_DIR, 'scalers')
MODEL_DIR = os.path.join(BASE_DIR, 'models')
LOG_DIR = os.path.join(BASE_DIR, 'logs')
TFLITE_DIR = os.path.join(BASE_DIR, 'tflite')
REPORT_DIR = os.path.join(BASE_DIR, 'reports')

PARK_CSV = os.path.join(BASE_DIR, 'park2024_real_dataset.csv')

# Flutter app assets (smarttear/ sibling of ml_training/)
REPO_ROOT = os.path.dirname(BASE_DIR)
FLUTTER_ASSETS = os.path.join(REPO_ROOT, 'smarttear', 'assets')
FLUTTER_MODELS = os.path.join(FLUTTER_ASSETS, 'models')
FLUTTER_CONFIG = os.path.join(FLUTTER_ASSETS, 'config')


def ensure_dirs(*names):
    """Create standard pipeline output directories."""
    mapping = {
        'datasets': DATASET_DIR,
        'splits': SPLIT_DIR,
        'scalers': SCALER_DIR,
        'models': MODEL_DIR,
        'logs': LOG_DIR,
        'tflite': TFLITE_DIR,
        'reports': REPORT_DIR,
    }
    targets = [mapping[n] for n in names] if names else mapping.values()
    for path in targets:
        os.makedirs(path, exist_ok=True)
