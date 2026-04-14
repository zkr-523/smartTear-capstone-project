# SmartTear — Step 2: Build feature vectors and save scaler params
# Run after generate_training_data.py
# Produces: features.csv and scaler_params.json
#
# CRITICAL: This preprocessing logic must match Dart Preprocessor exactly.
# If you change anything here, update lib/infrastructure/ml/preprocessor.dart too.

import numpy as np
import pandas as pd
import json

df = pd.read_csv('training_data.csv')
channel_cols = [f'ch{i}' for i in range(8)]
raw = df[channel_cols].values

# Step 1 — Clip at mean +/- 3*std (per channel)
clip_min = []
clip_max = []
for i in range(8):
    mean = raw[:, i].mean()
    std  = raw[:, i].std()
    clip_min.append(float(mean - 3 * std))
    clip_max.append(float(mean + 3 * std))

clipped = np.clip(raw, np.array(clip_min), np.array(clip_max))

# Step 2 — MinMax normalize (computed on clipped values)
feature_min = clipped.min(axis=0).tolist()
feature_max = clipped.max(axis=0).tolist()

normalized = np.zeros_like(clipped)
for i in range(8):
    denom = feature_max[i] - feature_min[i]
    if denom == 0:
        normalized[:, i] = 0.0
    else:
        normalized[:, i] = (clipped[:, i] - feature_min[i]) / denom
normalized = np.clip(normalized, 0.0, 1.0)

# Step 3 — Contact duration feature (normalize 0-3s to 0-1)
contact = df['contact_duration_s'].values
contact_feature = np.clip(contact / 3.0, 0.0, 1.0)

# Step 4 — Build 9-element feature vector
features = np.column_stack([normalized, contact_feature])
assert features.shape[1] == 9, f"Expected 9 features, got {features.shape[1]}"

# Save scaler params — these go into assets/config/scaler_params.json
scaler_params = {
    "featureMin": feature_min,
    "featureMax": feature_max,
    "clipMin":    clip_min,
    "clipMax":    clip_max,
}
with open('scaler_params.json', 'w') as f:
    json.dump(scaler_params, f, indent=2)
print("Saved scaler_params.json")

# Save feature matrix with labels
feature_df = pd.DataFrame(features, columns=[f'f{i}' for i in range(9)])
label_cols = ['glucose_mmol', 'sodium_meq', 'potassium_meq', 'chloride_meq', 'cholesterol']
for col in label_cols:
    feature_df[col] = df[col].values

feature_df.to_csv('features.csv', index=False)
print(f"Saved features.csv — shape {feature_df.shape}")
print("\nScaler params (first 3 channels):")
for i in range(3):
    print(f"  ch{i}: min={feature_min[i]:.4f}  max={feature_max[i]:.4f}  clip=[{clip_min[i]:.4f}, {clip_max[i]:.4f}]")

