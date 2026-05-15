# SmartTear — Tear-Fluid Biosensor Mobile App

**SE 496 Capstone Project · Alfaisal University · Spring 2026**

SmartTear is a Flutter mobile and web application that simulates a portable tear-fluid biosensor. A user pairs a (simulated) device, collects a tear sample, and receives on-device machine-learning estimates for tear glucose, electrolytes (Na, K, Cl), and cholesterol — without uploading health readings to Firebase or proprietary health clouds. An AI assistant (ZKR, powered by Gemini via Replit) answers questions about each reading.

> **Hardware note.** Physical hardware was scoped out of this capstone. A Python FastAPI server hosted on Replit stands in for a real BLE sensor device, generating realistic 8-channel sensor packets on request. **All TFLite inference runs locally inside the Flutter app.**

For a **product-facing narrative** (user journey, privacy, disclaimers), see **`PRODUCT.md`**.

---

## Repository Layout

```
smartTear-capstone-project/
├── smarttear/                  Flutter application
│   ├── lib/
│   │   ├── application/        Riverpod state providers
│   │   ├── domain/             Entities, ports, reference ranges
│   │   ├── infrastructure/
│   │   │   ├── ml/             Preprocessor, TFLite wrappers, QC, DataIngestor
│   │   │   ├── simulation/     SimulationConnector → Replit HTTP
│   │   │   ├── assistant/      ChatAssistantService → Replit /chat → Gemini
│   │   │   ├── auth/           Firebase Auth service
│   │   │   ├── database/       Drift + SQLCipher local DB
│   │   │   └── repositories/   Reading + chat message repositories
│   │   └── presentation/     Screens: home, results, history, trends, chat, auth
│   └── assets/
│       ├── models/             *.tflite (glucose, electrolytes, cholesterol, tg_bg v1)
│       └── config/             scaler_params.json · qc_thresholds.json · model_manifest.json
│
├── ml_training/                Python ML pipeline
│   ├── run_pipeline.py         Runs steps 1–5 in sequence
│   ├── step1_generate_dataset.py
│   ├── step2_preprocess.py
│   ├── step3_train.py
│   ├── step4_export_tflite.py  Exports + auto-copies to smarttear/assets/
│   ├── step5_evaluate.py
│   ├── step6_train_tg_bg.py    TG→BG mapping model (run separately)
│   ├── park2024_real_dataset.csv
│   └── datasets/ · splits/ · scalers/ · models/ · tflite/ · logs/ · reports/
│
└── simulation_server/
    └── main.py                 Replit FastAPI server
```

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Flutter SDK | ≥ 3.24 (Dart ≥ 3.4.4) | Mobile / web app |
| Python | ≥ 3.10 | ML pipeline and simulation server |
| TensorFlow | 2.13 – 2.15 | Model training (step3) |
| NumPy / pandas / scikit-learn / scipy | latest stable | Pipeline steps 1–2 |
| Firebase project | — | Authentication (FlutterFire configured) |
| Replit account | — | Simulation server hosting |
| Gemini API key | — | ZKR chat assistant |

---

## Running the Flutter App

```bash
cd smarttear
flutter pub get
flutter run -d chrome        # web (default for development)
flutter run                  # auto-selects a connected Android device
```

After changing asset files or TFLite models, do a **full restart** (`R` in the terminal or re-run), not only hot reload, so assets are re-bundled.

The app connects to the live Replit server by default:

```
https://smart-tear-simulation--zkrST.replit.app
```

To point to a different server, update `kSimulationServerUrl` in `smarttear/lib/infrastructure/simulation/simulation_connector.dart`.

---

## ML Training Pipeline

### Setup

```bash
cd ml_training
pip install numpy pandas scipy scikit-learn tensorflow
```

### Run all five steps

```bash
python run_pipeline.py
```

`run_pipeline.py` runs all steps sequentially and does **not** skip completed steps. Each run regenerates datasets, splits, models, and exports.

### What each step does

| Step | Script | Output |
|---|---|---|
| 1 | `step1_generate_dataset.py` | `datasets/dataset_TG.csv` (~1,548 rows), `dataset_electrolytes.csv` (~650 rows), `dataset_cholesterol.csv` (~650 rows) |
| 2 | `step2_preprocess.py` | `splits/*.npy` (train/val/test 70/15/15), `scalers/scaler_*.json` |
| 3 | `step3_train.py` | `models/*_final.keras` (5-fold CV + early stopping) |
| 4 | `step4_export_tflite.py` | `tflite/*.tflite` (dynamic-range quantized); auto-copies to `smarttear/assets/` |
| 5 | `step5_evaluate.py` | `reports/evaluation_report.json` (MAE, RMSE, R², Parkes grid) |

### TG → BG mapping model (step 6, run separately)

```bash
python step6_train_tg_bg.py
```

Trains a neural network on 208 real paired tear-glucose / blood-glucose measurements from Park et al. 2024. Outputs `tflite/tg_bg_model_v1.tflite` and `scalers/scaler_tg_bg.json`. Copy both to `smarttear/assets/` (models + config) if they are not already present after your workflow.

### Published model results (test set)

| Analyte | MAE | R² | Notes |
|---|---|---|---|
| Tear Glucose | 0.053 mmol/L | 0.885 | Parkes A+B: 97.3% |
| Sodium | 4.55 mEq/L | 0.354 | Synthetic Nernst data |
| Potassium | 1.14 mEq/L | 0.184 | Synthetic Nernst data |
| Chloride | 4.56 mEq/L | 0.390 | Synthetic Nernst data |
| Cholesterol | 0.358 mmol/L | 0.349 | Synthetic Song calibration |

Glucose performance is strong because training labels come from real in-vivo measurements (Park et al. 2024, Nature Communications). Electrolyte and cholesterol models are weaker because no real raw ISE dataset is publicly available; they are trained on physics-based synthetic data derived from published clinical statistics.

### Training data sources

| Analyte | Source | Method |
|---|---|---|
| TG | Park et al. 2024, *Nature Comms* | Real in-vivo, 1,407 measurements. Sensor signal: `ΔI/I₀ = 20.44 × TG_mM` (Fig 1e calibration, R² = 0.999) |
| TG→BG | Park et al. 2024 | 208 real simultaneous (TG, BG) pairs from human + diabetic subjects |
| Na, K, Cl | Calimon et al. 2024 (systematic review, 50 subjects) | Nernst ISE equation: `V = E₀ + 59.16 × log₁₀([ion])` |
| Cholesterol | Song et al. 2022, *Advanced Science* | Linear calibration: `ΔI/I₀ = 15.50 × Chol_mM` |

---

## Simulation Server (Replit)

### Deploy

1. Open your Replit project (Python template).
2. Paste `simulation_server/main.py` as `main.py`.
3. In **Secrets**, add `GEMINI_API_KEY` with your Google AI Studio key.
4. Click **Run**.

### Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/pair` | POST | Accepts `{ "device_id": "..." }`, marks device connected |
| `/reading` | GET | Returns 8 raw channels (0–1), `contact_duration_ms`, `sample_status` |
| `/status` | GET | Returns connection state and last reading timestamp |
| `/chat` | POST | Proxies message + reading context to Gemini 2.0 Flash |

The server **does not run ML**. It generates raw channels and forwards chat requests. All TFLite inference happens in the Flutter app.

### Channel map

```
channel[0]  tear_glucose proxy   (stratified / literature-inspired range)
channel[1]  sodium proxy         (0.50 – 0.75)
channel[2]  potassium proxy      (0.30 – 0.60)
channel[3]  chloride proxy       (0.40 – 0.70)
channel[4]  cholesterol proxy    (0.20 – 0.50)
channel[5]  pH proxy             (0.45 – 0.65)
channel[6]  temperature proxy    (0.48 – 0.55)
channel[7]  noise channel        (0.00 – 0.15)
```

The server implementation may stratify proxies (e.g. glucose channel) so labels are not always HIGH; see `simulation_server/main.py` for current distributions. A fraction of readings use short contact or partial/failed status to exercise QC.

---

## Flutter ML Runtime Path

```
Replit GET /reading
  → DataPackage (8 rawChannels, contactDurationMs, sampleStatus)
    → PackageValidator          (status + contact duration checks)
      → Preprocessor            (clip + MinMax from scaler_params.json;
                                  contact: (ms−500)/(2500−500))
        → 9-feature vector
          → glucose_model       → TG mmol/L
          → electrolytes_model  → Na, K, Cl mEq/L
          → cholesterol_model   → Chol mmol/L
          → tg_bg_model         → estimated BG mmol/L (optional, Settings)
            → QCClassifier      (qc_thresholds.json)
              → Reading saved to encrypted local DB (SQLCipher/Drift)
```

**Key config files:**

| File | Role |
|---|---|
| `assets/config/scaler_params.json` | MinMax feature bounds; contact duration normalization params |
| `assets/config/qc_thresholds.json` | `glucose_min: 0.05`, `glucose_max: 3.0`, `min_contact_duration_ms: 500` |
| `assets/config/model_manifest.json` | Maps model keys to `.tflite` filenames |
| `assets/config/scaler_tg_bg.json` | Scaler metadata for TG→BG model |

`step4_export_tflite.py` overwrites standard `.tflite` files and `scaler_params.json` in `smarttear/assets/` automatically. After **step 6**, ensure `tg_bg_model_v1.tflite` and `scaler_tg_bg.json` are under `smarttear/assets/`.

---

## Testing Tips

1. Run the app and sign in (or register) with Firebase email/password.
2. Tap **Pair Device** on the home screen. The app calls `POST /pair` on Replit.
3. Tap **Take Reading**. The app calls `GET /reading`, runs TFLite models, applies QC, and saves the result.
4. View results on the Results screen. Invalid readings show the reason and a retake option.
5. Open the Chat screen (ZKR). Attach the reading using the book icon, then type a question.
6. Check the History and Trends screens after several readings.

---

## Known Limitations

- **Electrolyte and cholesterol models** are trained on synthetic data derived from published statistics. There is no public raw ISE biosensor tear dataset; reported R² for those heads reflects honest ceiling.
- **Channel independence.** The Replit server generates channels from its model; coupling differs from physical hardware.
- **No regulated hardware.** This project does not constitute a regulated medical device.
- **TG→BG estimation** has inherent uncertainty and physiological lag (~10 minutes). Not a substitute for a certified BG meter.

---

## Git Notes

Do **not** commit:

- `ml_training/.venv/`
- `smarttear/.dart_tool/chrome-device/`
- Any `.pyc` or `__pycache__` directories

These should be ignored by `.gitignore`; verify before pushing large artefacts.

---

## Team — Students

| Name | Student ID | Role |
|---|---|---|
| **Zakariya Ba Alawi** | 220027 | Machine Learning Engineer |
| **Mohammed Bawazir** | 230035 | Team Lead · Architecture |
| **Ahmed Bin Halabi** | 220026 | Data · Backend |
| **Saad Alkeridis** | 220621 | UI/UX Design |
| **Mohammed Haythem** | 220601 | QA · Integration |

## Supervisor — Faculty

**Prof. Nidal Nasser** — Project supervisor.

**Institution:** Software Engineering Department, College of Engineering & Advanced Computing, Alfaisal University, Riyadh, Saudi Arabia.

**Course:** SE 496 — Capstone Project II · Spring 2026
