"""
SmartTear ML Pipeline — Step 6: TG → BG mapping model
======================================================
Trains a small neural network on paired tear glucose (TG_mM) and blood
glucose (BG_mM) from Park et al. 2024 (Nature Communications).

Input features (polynomial): [TG_mM, TG_mM², TG_mM³]
Output: BG_mM (mmol/L)

Exports:
  tflite/tg_bg_model_v1.tflite
  scalers/scaler_tg_bg.json
"""

import json
import os

import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import MinMaxScaler

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
tf.random.set_seed(42)
np.random.seed(42)

from paths import (
    FLUTTER_CONFIG,
    FLUTTER_MODELS,
    PARK_CSV,
    SCALER_DIR,
    TFLITE_DIR,
    ensure_dirs,
)

ensure_dirs("tflite", "scalers")


def load_paired_data():
    df = pd.read_csv(PARK_CSV)
    df = df[df["subject_type"] != "calibration"].copy()
    df = df.dropna(subset=["TG_mM", "BG_mM"])
    df = df[(df["TG_mM"] > 0) & (df["BG_mM"] > 0)].copy()
    # Prefer human subjects; include beagle if needed for sample size
    human = df[df["subject_type"] == "human"]
    if len(human) >= 100:
        df = human
    return df.reset_index(drop=True)


def poly_features(tg: np.ndarray) -> np.ndarray:
    tg = tg.reshape(-1, 1)
    return np.hstack([tg, tg**2, tg**3])


def build_model():
    inp = tf.keras.Input(shape=(3,), name="tg_poly")
    x = tf.keras.layers.Dense(32, activation="relu")(inp)
    x = tf.keras.layers.Dropout(0.15)(x)
    x = tf.keras.layers.Dense(16, activation="relu")(x)
    out = tf.keras.layers.Dense(1, activation="linear", name="BG_mM")(x)
    model = tf.keras.Model(inp, out)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, weight_decay=1e-5),
        loss=tf.keras.losses.Huber(delta=0.5),
        metrics=["mae"],
    )
    return model


def main():
    print("=" * 60)
    print("STEP 6: TG to BG model (Park et al. 2024 paired data)")
    print("=" * 60)

    df = load_paired_data()
    print(f"  Paired samples: {len(df)}")
    print(f"  Subject mix:\n{df['subject_type'].value_counts().to_string()}")

    tg = df["TG_mM"].values.astype(np.float32)
    bg = df["BG_mM"].values.astype(np.float32)
    X_raw = poly_features(tg)

    scaler = MinMaxScaler(feature_range=(0, 1))
    X = scaler.fit_transform(X_raw).astype(np.float32)
    y = bg.reshape(-1, 1).astype(np.float32)

    scaler_path = os.path.join(SCALER_DIR, "scaler_tg_bg.json")
    with open(scaler_path, "w", encoding="utf-8") as f:
        json.dump(
            {
                "feature_min": scaler.data_min_.tolist(),
                "feature_max": scaler.data_max_.tolist(),
                "n_samples": int(len(df)),
                "source": "Park et al. 2024 — paired TG_mM and BG_mM",
            },
            f,
            indent=2,
        )
    print(f"  Scaler saved: {scaler_path}")

    # 5-fold CV on human-relevant paired set
    kf = KFold(n_splits=5, shuffle=True, random_state=42)
    r2s, maes = [], []
    for fold, (tr, te) in enumerate(kf.split(X), 1):
        m = build_model()
        m.fit(
            X[tr],
            y[tr],
            validation_data=(X[te], y[te]),
            epochs=300,
            batch_size=16,
            verbose=0,
            callbacks=[
                tf.keras.callbacks.EarlyStopping(
                    monitor="val_loss",
                    patience=30,
                    restore_best_weights=True,
                ),
            ],
        )
        pred = m.predict(X[te], verbose=0).ravel()
        r2 = r2_score(y[te], pred)
        mae = mean_absolute_error(y[te], pred)
        r2s.append(r2)
        maes.append(mae)
        print(f"  Fold {fold}: R²={r2:.3f}  MAE={mae:.3f} mmol/L")

    print(f"  CV mean R²={np.mean(r2s):.3f}  MAE={np.mean(maes):.3f} mmol/L")

    # Final model on all data
    model = build_model()
    model.fit(
        X,
        y,
        epochs=400,
        batch_size=16,
        verbose=0,
        callbacks=[
            tf.keras.callbacks.EarlyStopping(
                monitor="loss", patience=40, restore_best_weights=True
            ),
        ],
    )

    keras_path = os.path.join(SCALER_DIR, "tg_bg_final.keras")
    model.save(keras_path)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_bytes = converter.convert()
    tflite_path = os.path.join(TFLITE_DIR, "tg_bg_model_v1.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_bytes)
    print(f"  TFLite saved: {tflite_path} ({len(tflite_bytes) / 1024:.1f} KB)")

    os.makedirs(FLUTTER_MODELS, exist_ok=True)
    os.makedirs(FLUTTER_CONFIG, exist_ok=True)
    import shutil

    shutil.copy2(tflite_path, os.path.join(FLUTTER_MODELS, "tg_bg_model_v1.tflite"))
    shutil.copy2(scaler_path, os.path.join(FLUTTER_CONFIG, "scaler_tg_bg.json"))
    print(f"  Copied to {FLUTTER_MODELS}")
    print(f"  Copied to {FLUTTER_CONFIG}")
    print("  Done.")


if __name__ == "__main__":
    main()
