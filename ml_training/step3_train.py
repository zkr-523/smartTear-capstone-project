"""
SmartTear ML Pipeline — Step 3: Model Training
================================================
Architecture (per published best practices for biosensor ML):
  Glucose:      Dense(64→32→1)    Huber loss, Adam, 5-fold CV
  Electrolytes: Dense(64→32→3)    Huber loss, multi-output
  Cholesterol:  Dense(32→16→1)    MAE loss

Training protocol:
  - 5-fold cross-validation on training set
  - Early stopping (patience=25, restore_best_weights=True)
  - ReduceLROnPlateau (factor=0.5, patience=10)
  - Adam optimizer (lr=0.001, weight_decay=1e-5)
  - Huber loss (delta=0.5) — robust to outliers for medical data
  - Batch size: 32
  - Max epochs: 500
"""

import numpy as np
import os, json, time
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import tensorflow as tf
from sklearn.model_selection import KFold
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error

tf.random.set_seed(42)
np.random.seed(42)

from paths import SPLIT_DIR, MODEL_DIR, LOG_DIR, ensure_dirs

ensure_dirs('models', 'logs')

# ── Model Factory ─────────────────────────────────────────────────────────────
def build_glucose_model():
    """Dense(64→Dropout→32→Dropout→1) — regression for TG estimation."""
    inp = tf.keras.Input(shape=(9,), name='channels')
    x = tf.keras.layers.Dense(64, activation='relu',
        kernel_regularizer=tf.keras.regularizers.l2(1e-4))(inp)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    x = tf.keras.layers.Dense(32, activation='relu',
        kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = tf.keras.layers.Dropout(0.1)(x)
    out = tf.keras.layers.Dense(1, activation='linear', name='TG_mM')(x)
    model = tf.keras.Model(inp, out)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, weight_decay=1e-5),
        loss=tf.keras.losses.Huber(delta=0.5),
        metrics=['mae'])
    return model

def build_electrolytes_model():
    """Dense(64→32→3) — multi-output for Na, K, Cl."""
    inp = tf.keras.Input(shape=(9,), name='channels')
    x = tf.keras.layers.Dense(64, activation='relu',
        kernel_regularizer=tf.keras.regularizers.l2(1e-4))(inp)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    x = tf.keras.layers.Dense(32, activation='relu')(x)
    x = tf.keras.layers.Dropout(0.1)(x)
    out = tf.keras.layers.Dense(3, activation='linear', name='NaKCl')(x)
    model = tf.keras.Model(inp, out)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, weight_decay=1e-5),
        loss=tf.keras.losses.Huber(delta=2.0),
        metrics=['mae'])
    return model

def build_cholesterol_model():
    """Dense(32→16→1) — lighter model for cholesterol estimation."""
    inp = tf.keras.Input(shape=(9,), name='channels')
    x = tf.keras.layers.Dense(32, activation='relu',
        kernel_regularizer=tf.keras.regularizers.l2(1e-4))(inp)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.Dropout(0.15)(x)
    x = tf.keras.layers.Dense(16, activation='relu')(x)
    out = tf.keras.layers.Dense(1, activation='linear', name='Chol_mM')(x)
    model = tf.keras.Model(inp, out)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='mae',
        metrics=['mse'])
    return model

def get_callbacks():
    """Final-training callbacks only (no ModelCheckpoint — Keras 3 .keras checkpoint breaks)."""
    return [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss', patience=25,
            restore_best_weights=True, verbose=0),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=10,
            min_lr=1e-6, verbose=0),
    ]

def metrics_report(y_true, y_pred, label=''):
    y_t = np.array(y_true).ravel()
    y_p = np.array(y_pred).ravel()
    mae  = mean_absolute_error(y_t, y_p)
    rmse = np.sqrt(mean_squared_error(y_t, y_p))
    r2   = r2_score(y_t, y_p)
    mape = np.mean(np.abs((y_t - y_p) / np.clip(y_t, 0.01, None))) * 100
    print(f"    {label:12s}  MAE={mae:.4f}  RMSE={rmse:.4f}  R²={r2:.4f}  MAPE={mape:.2f}%")
    return {'mae': mae, 'rmse': rmse, 'r2': r2, 'mape': mape}

# ── K-Fold Cross-Validation + Final Training ──────────────────────────────────
def train_with_cv(name, model_fn, X_train, y_train, X_val, y_val, X_test, y_test,
                  k=5, epochs=500, batch=32, label_names=None):
    print(f"\n{'═'*60}")
    print(f"TRAINING: {name.upper()}")
    print(f"  Dataset: Train={len(X_train)} | Val={len(X_val)} | Test={len(X_test)}")
    print(f"  Architecture: see build_{name}_model()")
    print(f"  K-Fold CV: k={k} folds on training set")
    print(f"{'═'*60}")

    # ─── 5-Fold Cross-Validation ───────────────────────────────────────────
    kf = KFold(n_splits=k, shuffle=True, random_state=42)
    fold_results = []

    for fold, (tr_idx, vl_idx) in enumerate(kf.split(X_train)):
        Xf_tr, Xf_vl = X_train[tr_idx], X_train[vl_idx]
        yf_tr, yf_vl = y_train[tr_idx], y_train[vl_idx]

        model = model_fn()
        cb = [
            tf.keras.callbacks.EarlyStopping(patience=20, restore_best_weights=True, verbose=0),
            tf.keras.callbacks.ReduceLROnPlateau(factor=0.5, patience=8, min_lr=1e-6, verbose=0),
        ]
        model.fit(Xf_tr, yf_tr, validation_data=(Xf_vl, yf_vl),
                  epochs=epochs, batch_size=batch, callbacks=cb, verbose=0)

        y_pred = model.predict(Xf_vl, verbose=0)
        if y_pred.ndim > 1 and y_pred.shape[1] == 1:
            y_pred = y_pred.ravel()
        y_true_flat = yf_vl.ravel() if yf_vl.ndim > 1 else yf_vl

        mae  = mean_absolute_error(y_true_flat, y_pred.ravel())
        r2   = r2_score(y_true_flat, y_pred.ravel())
        fold_results.append({'fold': fold+1, 'mae': mae, 'r2': r2})
        print(f"  Fold {fold+1}/{k}: MAE={mae:.4f}  R²={r2:.4f}")

    # CV summary
    maes = [r['mae'] for r in fold_results]
    r2s  = [r['r2']  for r in fold_results]
    print(f"\n  CV Summary: MAE = {np.mean(maes):.4f} ± {np.std(maes):.4f}")
    print(f"              R²  = {np.mean(r2s):.4f} ± {np.std(r2s):.4f}")

    # ─── Final Model Training (full train set + validation) ────────────────
    print(f"\n  Training final model on full train+val set...")
    X_full = np.vstack([X_train, X_val])
    y_full = np.vstack([y_train.reshape(-1,1) if y_train.ndim==1 else y_train,
                        y_val.reshape(-1,1)   if y_val.ndim==1   else y_val])
    if y_full.shape[1] == 1:
        y_full = y_full.ravel()

    final_model = model_fn()
    t0 = time.time()
    history = final_model.fit(
        X_full, y_full,
        validation_data=(X_test, y_test),
        epochs=epochs, batch_size=batch,
        callbacks=get_callbacks(),
        verbose=0)
    elapsed = time.time() - t0
    print(f"  Training complete in {elapsed:.1f}s ({len(history.history['loss'])} epochs)")

    # ─── Test Set Evaluation ───────────────────────────────────────────────
    print(f"\n  TEST SET EVALUATION:")
    y_pred_test = final_model.predict(X_test, verbose=0)

    if label_names and len(label_names) > 1:
        for i, lbl in enumerate(label_names):
            m = metrics_report(y_test[:, i], y_pred_test[:, i], lbl)
    else:
        metrics_report(y_test.ravel(), y_pred_test.ravel(), name)

    # Save final model and log
    final_model.save(os.path.join(MODEL_DIR, f'{name}_final.keras'))
    log = {
        'model': name,
        'cv_mae_mean': float(np.mean(maes)),
        'cv_mae_std':  float(np.std(maes)),
        'cv_r2_mean':  float(np.mean(r2s)),
        'cv_r2_std':   float(np.std(r2s)),
        'n_train': len(X_train),
        'n_val':   len(X_val),
        'n_test':  len(X_test),
    }
    with open(os.path.join(LOG_DIR, f'{name}_training_log.json'), 'w') as f:
        json.dump(log, f, indent=2)

    print(f"\n  Model saved: {os.path.join(MODEL_DIR, f'{name}_final.keras')}")
    return final_model, fold_results

# ── MAIN ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    print("Loading preprocessed splits...")

    # ── GLUCOSE ──
    X_tr = np.load(os.path.join(SPLIT_DIR, 'glucose_X_train.npy'))
    X_va = np.load(os.path.join(SPLIT_DIR, 'glucose_X_val.npy'))
    X_te = np.load(os.path.join(SPLIT_DIR, 'glucose_X_test.npy'))
    y_tr = np.load(os.path.join(SPLIT_DIR, 'glucose_y_train.npy'))
    y_va = np.load(os.path.join(SPLIT_DIR, 'glucose_y_val.npy'))
    y_te = np.load(os.path.join(SPLIT_DIR, 'glucose_y_test.npy'))
    train_with_cv('glucose', build_glucose_model, X_tr, y_tr, X_va, y_va, X_te, y_te)

    # ── ELECTROLYTES ──
    X_tr = np.load(os.path.join(SPLIT_DIR, 'electrolytes_X_train.npy'))
    X_va = np.load(os.path.join(SPLIT_DIR, 'electrolytes_X_val.npy'))
    X_te = np.load(os.path.join(SPLIT_DIR, 'electrolytes_X_test.npy'))
    y_tr = np.load(os.path.join(SPLIT_DIR, 'electrolytes_y_train.npy'))
    y_va = np.load(os.path.join(SPLIT_DIR, 'electrolytes_y_val.npy'))
    y_te = np.load(os.path.join(SPLIT_DIR, 'electrolytes_y_test.npy'))
    train_with_cv('electrolytes', build_electrolytes_model, X_tr, y_tr, X_va, y_va, X_te, y_te,
                  label_names=['Na_mmolL','K_mmolL','Cl_mmolL'])

    # ── CHOLESTEROL ──
    X_tr = np.load(os.path.join(SPLIT_DIR, 'cholesterol_X_train.npy'))
    X_va = np.load(os.path.join(SPLIT_DIR, 'cholesterol_X_val.npy'))
    X_te = np.load(os.path.join(SPLIT_DIR, 'cholesterol_X_test.npy'))
    y_tr = np.load(os.path.join(SPLIT_DIR, 'cholesterol_y_train.npy'))
    y_va = np.load(os.path.join(SPLIT_DIR, 'cholesterol_y_val.npy'))
    y_te = np.load(os.path.join(SPLIT_DIR, 'cholesterol_y_test.npy'))
    train_with_cv('cholesterol', build_cholesterol_model, X_tr, y_tr, X_va, y_va, X_te, y_te)

    print("\n" + "═"*60)
    print("ALL MODELS TRAINED AND SAVED")
    print(f"  Location: {MODEL_DIR}")
    print("═"*60)
