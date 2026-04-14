# SmartTear — Step 5: Verify Python preprocessing matches Dart Preprocessor
#
# Run after build_features.py.
# Copy the 3 printed feature vectors.
# Feed the same 3 raw_channels into your Dart Preprocessor
# using the scaler_params.json copied to assets/config/
# Numbers must match within 0.001 tolerance.
# If they differ — fix lib/infrastructure/ml/preprocessor.dart before continuing.

import numpy as np
import json

with open('scaler_params.json') as f:
    s = json.load(f)

CLIP_MIN    = np.array(s['clipMin'])
CLIP_MAX    = np.array(s['clipMax'])
FEATURE_MIN = np.array(s['featureMin'])
FEATURE_MAX = np.array(s['featureMax'])


def preprocess(raw_channels: list, contact_duration_ms: int) -> list:
    """
    Exactly mirrors lib/infrastructure/ml/preprocessor.dart
    Step 1: Clip
    Step 2: MinMax normalize
    Step 3: Contact duration feature
    Step 4: Assemble 9-element vector
    """
    raw = np.array(raw_channels, dtype=float)

    # Step 1 — Clip
    clipped = np.clip(raw, CLIP_MIN, CLIP_MAX)

    # Step 2 — MinMax normalize
    denom = FEATURE_MAX - FEATURE_MIN
    denom = np.where(denom == 0, 1.0, denom)
    normalized = (clipped - FEATURE_MIN) / denom
    normalized = np.clip(normalized, 0.0, 1.0)

    # Step 3 — Contact duration
    contact_feature = float(np.clip(contact_duration_ms / 3000.0, 0.0, 1.0))

    # Step 4 — Assemble
    features = list(normalized) + [contact_feature]
    return [round(f, 6) for f in features]


TEST_PACKETS = [
    {
        'label': 'Packet A — typical valid reading',
        'raw_channels': [0.6234, 0.5891, 0.4102, 0.5567,
                         0.3341, 0.5123, 0.5034, 0.0821],
        'contact_duration_ms': 1500,
    },
    {
        'label': 'Packet B — low glucose, short contact',
        'raw_channels': [0.4100, 0.5200, 0.3100, 0.4200,
                         0.2100, 0.4600, 0.4900, 0.0300],
        'contact_duration_ms': 600,
    },
    {
        'label': 'Packet C — high values, long contact',
        'raw_channels': [0.8200, 0.7400, 0.5800, 0.6800,
                         0.4800, 0.6400, 0.5400, 0.1300],
        'contact_duration_ms': 2800,
    },
]

print("=" * 60)
print("PARITY CHECK — Compare these with Dart Preprocessor output")
print("=" * 60)

for packet in TEST_PACKETS:
    features = preprocess(
        packet['raw_channels'],
        packet['contact_duration_ms']
    )
    print(f"\n{packet['label']}")
    print(f"  raw_channels:        {packet['raw_channels']}")
    print(f"  contact_duration_ms: {packet['contact_duration_ms']}")
    print(f"  feature_vector (9):  {features}")

print("\n" + "=" * 60)
print("Copy these 3 feature vectors.")
print("Run the same 3 packets through your Dart Preprocessor.")
print("Numbers must match within 0.001 tolerance.")
print("If they differ — fix preprocessor.dart before training.")
print("=" * 60)

