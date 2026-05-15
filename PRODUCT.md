# SmartTear — Product Overview

**SE 496 Capstone Project · Alfaisal University · Spring 2026**

---

## What SmartTear Does

SmartTear is a mobile health application that analyses tear fluid to estimate five biomarkers: tear glucose, sodium, potassium, chloride, and cholesterol. The user briefly touches a sampling tip to the lower eyelid, and the app returns results in under a second — with no blood draw, no laboratory visit, and no health data leaving the device.

All machine-learning inference runs locally on the phone using TensorFlow Lite models. The app stores every reading in an encrypted local database, shows trends over time, and includes ZKR — an AI assistant that answers plain-language questions about what the numbers mean.

SmartTear is a university capstone demonstration. It is **not a certified medical device** and must not be used for clinical diagnosis or treatment decisions.

---

## User Journey

### 1. Sign In

The app requires an account to keep readings private and device-local. Users register with an email address and password. Authentication is handled by Firebase; no health readings are uploaded to any cloud service.

### 2. Pair the Sensor

On the home screen, the user taps **Pair Device**. The app connects to the SmartTear simulation server, which acts as a stand-in for the physical biosensor hardware that would be used in a production version of the product. A successful pairing is indicated by the device status turning active.

> In this capstone prototype, the hardware component is simulated by a Python server running on Replit. The server generates realistic sensor signals; the app cannot distinguish between simulated and real data.

### 3. Take a Reading

The user taps **Take Reading**. The app requests a sensor packet from the paired device, receives eight raw channel values representing the biosensor output, and immediately runs neural-network models on the device to convert those values into biomarker concentrations.

The process takes less than one second from tap to result.

### 4. Quality Control (QC)

Every reading is automatically classified as **Valid** or **Invalid** before the results are shown.

A reading is marked Invalid if any of the following conditions are detected:

| Reason | Description |
|---|---|
| Contact too short | The sampling tip was held against the eye for less than 500 milliseconds, which is insufficient to collect enough tear fluid |
| Weak signal | The sensor output variance is too low, indicating poor contact or a dry tip |
| Out-of-range glucose | The estimated tear glucose falls outside the physiological window of 0.05–3.0 mmol/L |
| Sample failed | The device reported an internal failure during the measurement |

When a reading is Invalid, the app shows the specific reason and offers an immediate **Retake** option.

### 5. View Results

For a valid reading, the Results screen displays each biomarker with its value, unit, and a colour-coded status indicator:

- **LOW** — below the normal reference range
- **NORMAL** — within the expected healthy range
- **HIGH** — above the normal reference range

A semi-circular gauge visualises tear glucose with a real-time arc. If the estimated blood glucose feature is enabled in Settings, the app also shows a blood glucose estimate derived from tear glucose using a model trained on 208 real paired measurements.

### 6. History and Trends

The History screen lists every reading in reverse chronological order. Tapping a reading opens the full detail view.

The Trends screen charts each analyte over the last 7, 30, or 90 days, making it easy to see whether values are stable, rising, or falling over time.

Readings can be exported as a CSV file from the History screen for further review.

### 7. Ask ZKR

ZKR is the SmartTear AI assistant, accessible from the Chat tab. The user can attach any reading to the conversation using the book icon, then ask questions in plain language.

Example questions ZKR can answer:

- "What does my tear glucose of 0.38 mean?"
- "Which analyte is most out of range?"
- "Should I see a doctor about this result?"
- "How does tear glucose relate to blood glucose?"

ZKR keeps answers short (typically two sentences) and uses the actual numbers from the reading rather than giving generic responses. ZKR remembers the recent conversation context across multiple turns.

> ZKR requires an active internet connection. Queries are sent to a Replit server, which forwards them to Google Gemini. The reading context is included in each request. ZKR is an informational assistant, not a clinical diagnostic tool.

---

## Biomarker Reference Ranges

The following **in-app display bands** drive LOW / NORMAL / HIGH labels (`analyte_reference_ranges.dart`). They are calibrated for the simulator and on-device TG model output alongside published tear-fluid context; tighter literature bands may differ.

| Biomarker | Unit | Low | Normal range | High | Notes |
|---|---|---|---|---|---|
| Tear Glucose (TG) | mmol/L | &lt; 0.30 | 0.30 – 0.85 | &gt; 0.85 | Elevated TG can correlate with blood glucose trends; not diagnostic |
| Sodium (Na⁺) | mEq/L | &lt; 120 | 120 – 165 | &gt; 165 | Electrolyte balance / tear film |
| Potassium (K⁺) | mEq/L | &lt; 20 | 20 – 42 | &gt; 42 | Intracellular ion |
| Chloride (Cl⁻) | mEq/L | &lt; 106 | 106 – 136 | &gt; 136 | Paired with sodium |
| Cholesterol | mmol/L | &lt; 0.5 | 0.5 – 3.0 | &gt; 3.0 | Meibomian / lipid relevance |

### Estimated Blood Glucose

When enabled in Settings, SmartTear displays an estimated blood glucose value derived from tear glucose using a neural network trained on 208 simultaneous (tear glucose, blood glucose) measurements from real human and diabetic subjects (Park et al. 2024, Nature Communications). The underlying paper reports strong correlation (~0.82) for suitable subjects — app performance follows the bundled TG→BG model.

This estimate is provided as a reference only. A physiological lag of approximately 10 minutes exists between changes in blood glucose and corresponding changes in tear glucose. A single-point estimate cannot account for this lag. Users should not rely on this value in place of a certified blood glucose measurement.

---

## Machine Learning Models

SmartTear runs neural networks entirely on the device:

| Model | Architecture | Training data | Test R² (typical) |
|---|---|---|---|
| Glucose | Dense | Park et al. 2024 (real in-vivo TG) | 0.885 |
| Electrolytes (Na/K/Cl) | Dense | Synthetic (Nernst + Calimon 2024 statistics) | 0.18–0.39 |
| Cholesterol | Dense | Synthetic (Song et al. 2022 calibration) | 0.349 |
| TG → BG mapping | Dense | 208 paired (TG, BG) Park 2024 | ≈ 0.74 |

Cross-validation during training uses Huber loss for robustness; models are exported to TFLite with dynamic-range quantisation for on-device inference. Models are bundled in the app; no runtime model download.

Glucose model performance referenced in evaluation satisfies the Parkes Error Grid criterion: a high fraction of test predictions fall within Zones A and B (clinically acceptable ranges in validation reports).

---

## Privacy

| Data type | Where it goes |
|---|---|
| Biomarker readings | Stored only on the local device in an AES-256 encrypted database (SQLCipher). Never uploaded. |
| Account credentials | Managed by Firebase Authentication. Only email and password hash are stored with Firebase. |
| Chat messages | Sent to the Replit server and forwarded to Google Gemini for processing. Reading values included in the request. |
| Raw sensor channels | Received from the simulation server. Not persisted beyond the current reading session. |

Users who prefer not to use the ZKR chat feature can avoid it entirely; all other functions work offline after initial authentication.

---

## Disclaimer

SmartTear is a university research and engineering demonstration developed as part of the SE 496 Capstone Programme at Alfaisal University. It has not been evaluated, validated, or approved as a medical device by any regulatory body. The biomarker estimates it produces are approximations intended for educational purposes only.

**SmartTear must not be used to diagnose, treat, monitor, or make decisions about any medical condition.** Users who have concerns about their blood glucose, electrolyte balance, or cholesterol levels should consult a qualified healthcare professional and use certified medical equipment.

---

## About the Project

SmartTear was developed over Spring 2026 as a student capstone project at Alfaisal University. Scope covers mobile software engineering: clean architecture in Flutter, on-device machine learning with TFLite, encrypted local storage, AI-assisted UX, and a literature-grounded ML training pipeline.

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
