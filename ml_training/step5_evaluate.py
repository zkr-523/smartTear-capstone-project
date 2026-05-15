"""
SmartTear ML Pipeline — Step 5: Comprehensive Evaluation
=========================================================
Evaluation metrics:
  - MAE, RMSE, R², MAPE  (all models)
  - Parkes Error Grid     (glucose — clinical standard)
  - Per-analyte breakdown (electrolytes)
  - Confidence intervals via bootstrap (1000 iterations)
  - Final summary report saved as JSON
"""

import numpy as np
import json, os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error

from paths import SPLIT_DIR, MODEL_DIR, REPORT_DIR, ensure_dirs

ensure_dirs('reports')

def bootstrap_ci(y_true, y_pred, metric_fn, n_boot=1000, ci=0.95):
    """Bootstrap confidence interval for any metric."""
    scores = []
    n = len(y_true)
    for _ in range(n_boot):
        idx = np.random.choice(n, n, replace=True)
        try:
            s = metric_fn(y_true[idx], y_pred[idx])
            scores.append(s)
        except:
            pass
    lo = np.percentile(scores, (1-ci)/2*100)
    hi = np.percentile(scores, (1-(1-ci)/2)*100)
    return float(np.mean(scores)), float(lo), float(hi)

def compute_metrics(y_true, y_pred, name=''):
    """Full metrics suite with bootstrap CIs."""
    y_t = np.array(y_true).ravel()
    y_p = np.array(y_pred).ravel()

    mae   = mean_absolute_error(y_t, y_p)
    rmse  = np.sqrt(mean_squared_error(y_t, y_p))
    r2    = r2_score(y_t, y_p)
    mape  = np.mean(np.abs((y_t - y_p) / np.clip(np.abs(y_t), 0.001, None))) * 100

    # Bootstrap 95% CI for R²
    r2_mean, r2_lo, r2_hi = bootstrap_ci(y_t, y_p, r2_score)
    mae_mean, mae_lo, mae_hi = bootstrap_ci(y_t, y_p, mean_absolute_error)

    result = {
        'name': name,
        'n':    int(len(y_t)),
        'mae':  float(mae),  'mae_ci': [float(mae_lo), float(mae_hi)],
        'rmse': float(rmse),
        'r2':   float(r2),   'r2_ci':  [float(r2_lo),  float(r2_hi)],
        'mape': float(mape),
    }
    print(f"  {name:14s} | n={len(y_t):4d} | MAE={mae:.4f} [{mae_lo:.4f},{mae_hi:.4f}] "
          f"| RMSE={rmse:.4f} | R²={r2:.4f} [{r2_lo:.4f},{r2_hi:.4f}] | MAPE={mape:.2f}%")
    return result

def parkes_error_grid_analysis(y_true_mM, y_pred_mM):
    """
    Simplified Parkes Error Grid for tear glucose.
    Zones A/B are clinically acceptable.
    Adapted for tear glucose range (0.1–2.0 mM).
    Reference: Parkes et al. Diabetes Care 2000.
    """
    y_t = np.array(y_true_mM)
    y_p = np.array(y_pred_mM)
    pct_err = (y_p - y_t) / np.clip(y_t, 0.05, None) * 100

    zone_A = np.abs(pct_err) <= 20
    zone_B = (np.abs(pct_err) > 20) & (np.abs(pct_err) <= 40)
    zone_CD = np.abs(pct_err) > 40

    n = len(y_t)
    print(f"\n  PARKES ERROR GRID (Glucose):")
    print(f"    Zone A (±20%): {zone_A.sum():3d}/{n} = {zone_A.mean()*100:.1f}%  [Clinically accurate]")
    print(f"    Zone B (±40%): {zone_B.sum():3d}/{n} = {zone_B.mean()*100:.1f}%  [Acceptable]")
    print(f"    Zone C/D >40%: {zone_CD.sum():3d}/{n} = {zone_CD.mean()*100:.1f}%  [Clinically concerning]")
    print(f"    A+B combined:  {(zone_A|zone_B).sum():3d}/{n} = {(zone_A|zone_B).mean()*100:.1f}%")

    return {
        'zone_A_pct': float(zone_A.mean()*100),
        'zone_B_pct': float(zone_B.mean()*100),
        'zone_CD_pct': float(zone_CD.mean()*100),
        'AB_combined_pct': float((zone_A|zone_B).mean()*100),
    }

def evaluate_glucose():
    print("\n" + "═"*65)
    print("GLUCOSE MODEL EVALUATION")
    print("═"*65)

    model = tf.keras.models.load_model(
        os.path.join(MODEL_DIR, 'glucose_final.keras'), compile=False)
    X_test = np.load(os.path.join(SPLIT_DIR, 'glucose_X_test.npy'))
    y_test = np.load(os.path.join(SPLIT_DIR, 'glucose_y_test.npy'))

    y_pred = model.predict(X_test, verbose=0).ravel()

    print(f"\n  Test set: {len(X_test)} samples")
    result = compute_metrics(y_test, y_pred, 'TG_mM')
    parkes = parkes_error_grid_analysis(y_test, y_pred)
    result['parkes'] = parkes

    # Range-stratified performance
    print(f"\n  RANGE ANALYSIS:")
    ranges = [('Low <0.3mM',  y_test < 0.3),
              ('Normal 0.3-0.5', (y_test >= 0.3) & (y_test < 0.5)),
              ('Elevated 0.5-1.0', (y_test >= 0.5) & (y_test < 1.0)),
              ('High >1.0mM',  y_test >= 1.0)]
    for rname, mask in ranges:
        if mask.sum() > 5:
            mae_r = mean_absolute_error(y_test[mask], y_pred[mask])
            r2_r  = r2_score(y_test[mask], y_pred[mask]) if mask.sum() > 2 else 0
            print(f"    {rname:22s}: n={mask.sum():3d}  MAE={mae_r:.4f}  R²={r2_r:.4f}")

    return result

def evaluate_electrolytes():
    print("\n" + "═"*65)
    print("ELECTROLYTES MODEL EVALUATION")
    print("═"*65)

    model = tf.keras.models.load_model(
        os.path.join(MODEL_DIR, 'electrolytes_final.keras'), compile=False)
    X_test = np.load(os.path.join(SPLIT_DIR, 'electrolytes_X_test.npy'))
    y_test = np.load(os.path.join(SPLIT_DIR, 'electrolytes_y_test.npy'))

    y_pred = model.predict(X_test, verbose=0)
    print(f"\n  Test set: {len(X_test)} samples")

    results = {}
    names = ['Na_mmolL', 'K_mmolL', 'Cl_mmolL']
    for i, name in enumerate(names):
        r = compute_metrics(y_test[:, i], y_pred[:, i], name)
        results[name] = r
    return results

def evaluate_cholesterol():
    print("\n" + "═"*65)
    print("CHOLESTEROL MODEL EVALUATION")
    print("═"*65)

    model = tf.keras.models.load_model(
        os.path.join(MODEL_DIR, 'cholesterol_final.keras'), compile=False)
    X_test = np.load(os.path.join(SPLIT_DIR, 'cholesterol_X_test.npy'))
    y_test = np.load(os.path.join(SPLIT_DIR, 'cholesterol_y_test.npy'))

    y_pred = model.predict(X_test, verbose=0).ravel()
    print(f"\n  Test set: {len(X_test)} samples")
    result = compute_metrics(y_test, y_pred, 'Chol_mM')

    print(f"\n  RANGE ANALYSIS:")
    ranges = [('Low <0.5mM',    y_test < 0.5),
              ('Normal 0.5-1.5', (y_test >= 0.5) & (y_test < 1.5)),
              ('High >1.5mM',   y_test >= 1.5)]
    for rname, mask in ranges:
        if mask.sum() > 5:
            mae_r = mean_absolute_error(y_test[mask], y_pred[mask])
            print(f"    {rname:22s}: n={mask.sum():3d}  MAE={mae_r:.4f}")

    return result

if __name__ == '__main__':
    all_results = {}

    r_glucose = evaluate_glucose()
    all_results['glucose'] = r_glucose

    r_electrolytes = evaluate_electrolytes()
    all_results['electrolytes'] = r_electrolytes

    r_cholesterol = evaluate_cholesterol()
    all_results['cholesterol'] = r_cholesterol

    # Save comprehensive report
    report_path = os.path.join(REPORT_DIR, 'evaluation_report.json')
    with open(report_path, 'w') as f:
        json.dump(all_results, f, indent=2)

    print("\n" + "═"*65)
    print("EVALUATION COMPLETE")
    print(f"  Full report: {report_path}")
    print()
    print("  SUMMARY:")
    if 'r2' in all_results.get('glucose', {}):
        g = all_results['glucose']
        print(f"  Glucose:      R²={g['r2']:.3f}  MAE={g['mae']:.4f} mM  "
              f"Zone A+B={g.get('parkes',{}).get('AB_combined_pct',0):.1f}%")
    for ana in ['Na_mmolL', 'K_mmolL', 'Cl_mmolL']:
        e = all_results.get('electrolytes', {}).get(ana, {})
        if e:
            print(f"  {ana:14s}: R²={e['r2']:.3f}  MAE={e['mae']:.3f} mmol/L")
    if 'r2' in all_results.get('cholesterol', {}):
        c = all_results['cholesterol']
        print(f"  Cholesterol:  R²={c['r2']:.3f}  MAE={c['mae']:.4f} mM")
    print("═"*65)
