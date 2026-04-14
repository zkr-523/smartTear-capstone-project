# SmartTear — Step 1: Generate synthetic training data
# Run this first. Produces training_data.csv

import numpy as np
import pandas as pd

np.random.seed(42)
N = 1000

# Channel ranges (matching simulation server exactly)
CHANNEL_RANGES = [
    (0.40, 0.85),  # 0: tear_glucose
    (0.50, 0.75),  # 1: sodium
    (0.30, 0.60),  # 2: potassium
    (0.40, 0.70),  # 3: chloride
    (0.20, 0.50),  # 4: cholesterol
    (0.45, 0.65),  # 5: pH
    (0.48, 0.55),  # 6: temperature
    (0.00, 0.15),  # 7: noise
]

NOISE_STD = 0.02

rows = []
for _ in range(N):
    channels = []
    for (low, high) in CHANNEL_RANGES:
        base = np.random.uniform(low, high)
        noisy = base + np.random.normal(0, NOISE_STD)
        clamped = float(np.clip(noisy, 0.0, 1.0))
        channels.append(clamped)

    contact_duration = np.random.uniform(0.0, 3.0)

    glucose_mmol   = channels[0] * 0.8  + 0.05 + np.random.normal(0, 0.03)
    sodium_meq     = channels[1] * 140  + 10   + np.random.normal(0, 2.0)
    potassium_meq  = channels[2] * 5    + 1    + np.random.normal(0, 0.2)
    chloride_meq   = channels[3] * 110  + 10   + np.random.normal(0, 2.0)
    cholesterol    = channels[4] * 5    + 1    + np.random.normal(0, 0.3)

    row = channels + [contact_duration,
                      glucose_mmol, sodium_meq, potassium_meq,
                      chloride_meq, cholesterol]
    rows.append(row)

columns = (
    [f'ch{i}' for i in range(8)]
    + ['contact_duration_s']
    + ['glucose_mmol', 'sodium_meq', 'potassium_meq',
       'chloride_meq', 'cholesterol']
)

df = pd.DataFrame(rows, columns=columns)
df.to_csv('training_data.csv', index=False)
print(f"Saved {len(df)} samples to training_data.csv")
print(df.describe().round(3))

