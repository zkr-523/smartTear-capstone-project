"""
SmartTear ML Pipeline — Step 2: Preprocessing & Split
======================================================
Advanced preprocessing for medical biosensor data:
  1. Outlier removal (IQR method per label group)
  2. Feature engineering (9-feature vector + contact duration)
  3. MinMax normalization with fitted scalers
  4. Stratified train / validation / test split (70/15/15)
  5. Quality report with distribution statistics
"""

import numpy as np
import pandas as pd
import json, os
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from scipy import stats

np.random.seed(42)

from paths import DATASET_DIR, SPLIT_DIR, SCALER_DIR, ensure_dirs

ensure_dirs('splits', 'scalers')

CHANNEL_COLS = ['ch0_tg_proxy','ch1_na_proxy','ch2_k_proxy','ch3_cl_proxy',
                'ch4_chol_proxy','ch5_ph_proxy','ch6_temp_proxy','ch7_noise']

def contact_normalize(ms_series):
    """Normalize contact duration: [500, 2500] ms → [0.2, 1.0]"""
    ms = np.clip(ms_series.values, 500, 2500)
    return (ms - 500) / (2500 - 500)

def remove_outliers_iqr(df, label_col, factor=2.5):
    """Remove outliers using IQR method on the label column."""
    Q1 = df[label_col].quantile(0.25)
    Q3 = df[label_col].quantile(0.75)
    IQR = Q3 - Q1
    lo, hi = Q1 - factor*IQR, Q3 + factor*IQR
    before = len(df)
    df_clean = df[(df[label_col] >= lo) & (df[label_col] <= hi)].copy()
    after = len(df_clean)
    print(f"  Outlier removal ({label_col}): {before} → {after} ({before-after} removed)")
    return df_clean

def build_feature_matrix(df):
    """Build the 9-feature normalized input matrix."""
    scaler = MinMaxScaler(feature_range=(0, 1))
    X_raw  = df[CHANNEL_COLS].values
    X_norm = scaler.fit_transform(X_raw)
    # Feature 9: normalized contact duration
    cd     = contact_normalize(df['contact_ms']).reshape(-1, 1)
    X_full = np.hstack([X_norm, cd])   # shape: (n, 9)
    return X_full, scaler

def stratified_split(X, y, stratify_col=None, test_size=0.15, val_size=0.15):
    """
    70% train / 15% val / 15% test
    Stratified on subject_type when available.
    """
    strat = stratify_col if stratify_col is not None else None
    X_trainval, X_test, y_trainval, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42, stratify=strat)
    val_frac = val_size / (1 - test_size)
    strat_tv = stratify_col[:len(X_trainval)] if strat is not None else None
    X_train, X_val, y_train, y_val = train_test_split(
        X_trainval, y_trainval, test_size=val_frac, random_state=42, stratify=strat_tv)
    return X_train, X_val, X_test, y_train, y_val, y_test

def quality_report(name, y_train, y_val, y_test, label):
    print(f"\n  [{name}] {label} — Quality Report")
    for split, y in [('TRAIN', y_train), ('VAL', y_val), ('TEST', y_test)]:
        if hasattr(y, 'shape') and y.ndim > 1:
            for i, col in enumerate(label if isinstance(label, list) else [label]):
                vals = y[:, i]
                print(f"    {split} {col}: n={len(vals)}, "
                      f"mean={vals.mean():.3f}, std={vals.std():.3f}, "
                      f"min={vals.min():.3f}, max={vals.max():.3f}")
        else:
            vals = np.array(y).ravel()
            print(f"    {split}: n={len(vals)}, mean={vals.mean():.3f}, "
                  f"std={vals.std():.3f}, min={vals.min():.3f}, max={vals.max():.3f}")

def save_scaler(scaler, name, channel_cols):
    """Save scaler parameters as JSON for Dart parity check."""
    params = {
        'feature_min':  scaler.data_min_.tolist(),
        'feature_max':  scaler.data_max_.tolist(),
        'scale':        scaler.scale_.tolist(),
        'channel_cols': channel_cols,
    }
    path = os.path.join(SCALER_DIR, f'scaler_{name}.json')
    with open(path, 'w') as f:
        json.dump(params, f, indent=2)
    print(f"  Scaler saved: {path}")
    return params

# ══════════════════════════════════════════════════════════════════════════════
# GLUCOSE PREPROCESSING
# ══════════════════════════════════════════════════════════════════════════════
def preprocess_glucose():
    print("═" * 60)
    print("GLUCOSE PREPROCESSING")
    print("═" * 60)

    df = pd.read_csv(os.path.join(DATASET_DIR, 'dataset_TG.csv'))
    print(f"  Loaded: {len(df)} samples")

    # Remove physiological outliers (TG > 3.0 mM is non-physiological for tears)
    df = df[df['TG_mM'] <= 3.0].copy()
    df = df[df['TG_mM'] >= 0.05].copy()  # minimum physiological baseline
    df = remove_outliers_iqr(df, 'TG_mM', factor=3.0)

    # Build 9-feature matrix
    X, scaler = build_feature_matrix(df)
    y = df['TG_mM'].values

    # Stratify by subject type for representative splits
    subject_map = {'human': 0, 'normal_beagle': 1, 'diabetic_beagle': 2,
                   'synthetic_clinical': 3}
    strat = df['subject_type'].map(subject_map).fillna(3).values

    X_tr, X_val, X_te, y_tr, y_val, y_te = stratified_split(X, y, strat)

    quality_report('Glucose', y_tr, y_val, y_te, 'TG_mM')
    save_scaler(scaler, 'glucose', CHANNEL_COLS)

    # Save splits
    np.save(os.path.join(SPLIT_DIR, 'glucose_X_train.npy'), X_tr)
    np.save(os.path.join(SPLIT_DIR, 'glucose_X_val.npy'), X_val)
    np.save(os.path.join(SPLIT_DIR, 'glucose_X_test.npy'), X_te)
    np.save(os.path.join(SPLIT_DIR, 'glucose_y_train.npy'), y_tr)
    np.save(os.path.join(SPLIT_DIR, 'glucose_y_val.npy'), y_val)
    np.save(os.path.join(SPLIT_DIR, 'glucose_y_test.npy'), y_te)

    print(f"\n  SPLIT SUMMARY:")
    print(f"    Train: {len(X_tr):,} | Val: {len(X_val):,} | Test: {len(X_te):,}")
    print(f"    Total: {len(X_tr)+len(X_val)+len(X_te):,} samples")
    return X_tr, X_val, X_te, y_tr, y_val, y_te

# ══════════════════════════════════════════════════════════════════════════════
# ELECTROLYTES PREPROCESSING
# ══════════════════════════════════════════════════════════════════════════════
def preprocess_electrolytes():
    print()
    print("═" * 60)
    print("ELECTROLYTES PREPROCESSING")
    print("═" * 60)

    df = pd.read_csv(os.path.join(DATASET_DIR, 'dataset_electrolytes.csv'))
    print(f"  Loaded: {len(df)} samples")

    # Physiological bounds (±4σ from Calimon 2024)
    df = df[(df['Na_mmolL'] >= 110) & (df['Na_mmolL'] <= 155)].copy()
    df = df[(df['K_mmolL']  >=  15) & (df['K_mmolL']  <=  28)].copy()
    df = df[(df['Cl_mmolL'] >= 100) & (df['Cl_mmolL'] <= 145)].copy()

    # Remove multivariate outliers using Mahalanobis distance
    elec_cols = ['Na_mmolL', 'K_mmolL', 'Cl_mmolL']
    cov = np.cov(df[elec_cols].T)
    mean_vec = df[elec_cols].mean().values
    dists = []
    for _, row in df[elec_cols].iterrows():
        diff = row.values - mean_vec
        try:
            d = np.sqrt(diff @ np.linalg.inv(cov) @ diff)
        except:
            d = 0
        dists.append(d)
    df['mahal_dist'] = dists
    threshold = stats.chi2.ppf(0.975, df=3)  # 97.5th percentile, 3 dof
    before = len(df)
    df = df[df['mahal_dist'] <= threshold].copy()
    print(f"  Mahalanobis outlier removal: {before} → {len(df)}")

    # Build feature matrix
    X, scaler = build_feature_matrix(df)
    y = df[['Na_mmolL', 'K_mmolL', 'Cl_mmolL']].values

    X_tr, X_val, X_te, y_tr, y_val, y_te = stratified_split(X, y)
    quality_report('Electrolytes', y_tr, y_val, y_te, ['Na','K','Cl'])
    save_scaler(scaler, 'electrolytes', CHANNEL_COLS)

    np.save(os.path.join(SPLIT_DIR, 'electrolytes_X_train.npy'), X_tr)
    np.save(os.path.join(SPLIT_DIR, 'electrolytes_X_val.npy'), X_val)
    np.save(os.path.join(SPLIT_DIR, 'electrolytes_X_test.npy'), X_te)
    np.save(os.path.join(SPLIT_DIR, 'electrolytes_y_train.npy'), y_tr)
    np.save(os.path.join(SPLIT_DIR, 'electrolytes_y_val.npy'), y_val)
    np.save(os.path.join(SPLIT_DIR, 'electrolytes_y_test.npy'), y_te)

    print(f"\n  SPLIT: Train {len(X_tr)} | Val {len(X_val)} | Test {len(X_te)}")
    return X_tr, X_val, X_te, y_tr, y_val, y_te

# ══════════════════════════════════════════════════════════════════════════════
# CHOLESTEROL PREPROCESSING
# ══════════════════════════════════════════════════════════════════════════════
def preprocess_cholesterol():
    print()
    print("═" * 60)
    print("CHOLESTEROL PREPROCESSING")
    print("═" * 60)

    df = pd.read_csv(os.path.join(DATASET_DIR, 'dataset_cholesterol.csv'))
    print(f"  Loaded: {len(df)} samples")

    # Physiological bounds: 0.1–3.0 mM (Song 2022 measurement range)
    df = df[(df['Chol_mM'] >= 0.1) & (df['Chol_mM'] <= 3.0)].copy()
    df = remove_outliers_iqr(df, 'Chol_mM', factor=2.5)

    X, scaler = build_feature_matrix(df)
    y = df['Chol_mM'].values

    strat = (df['subject_type'] == 'hyperlipidemic').astype(int).values
    X_tr, X_val, X_te, y_tr, y_val, y_te = stratified_split(X, y, strat)
    quality_report('Cholesterol', y_tr, y_val, y_te, 'Chol_mM')
    save_scaler(scaler, 'cholesterol', CHANNEL_COLS)

    np.save(os.path.join(SPLIT_DIR, 'cholesterol_X_train.npy'), X_tr)
    np.save(os.path.join(SPLIT_DIR, 'cholesterol_X_val.npy'), X_val)
    np.save(os.path.join(SPLIT_DIR, 'cholesterol_X_test.npy'), X_te)
    np.save(os.path.join(SPLIT_DIR, 'cholesterol_y_train.npy'), y_tr)
    np.save(os.path.join(SPLIT_DIR, 'cholesterol_y_val.npy'), y_val)
    np.save(os.path.join(SPLIT_DIR, 'cholesterol_y_test.npy'), y_te)

    print(f"\n  SPLIT: Train {len(X_tr)} | Val {len(X_val)} | Test {len(X_te)}")
    return X_tr, X_val, X_te, y_tr, y_val, y_te

# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════
if __name__ == '__main__':
    preprocess_glucose()
    preprocess_electrolytes()
    preprocess_cholesterol()

    print()
    print("═" * 60)
    print("ALL PREPROCESSING COMPLETE")
    print(f"  Splits saved to: {SPLIT_DIR}")
    print(f"  Scalers saved to: {SCALER_DIR}")
    print("═" * 60)
