# SmartTear Knowledge

## What this app does
SmartTear is a mobile health app that estimates biomarkers from tear fluid without blood or needles. A soft sensor tip briefly touches the eye surface to collect basal tear fluid, and the sensor captures 8 raw signal channels representing tear chemistry. The mobile app validates the packet, normalizes the channels, and runs three on-device TensorFlow Lite neural networks to estimate tear glucose, three electrolytes (sodium, potassium, chloride), and cholesterol. For this capstone the hardware is simulated by a Python FastAPI server hosted on Replit that returns the same packet format a real BLE device would send, so the rest of the pipeline (validation, ML inference, quality control, local storage) runs exactly as it would against real hardware.

## What the app can and cannot tell you
SmartTear gives estimates from a simulated tear biosensor pipeline for self-awareness and tracking. The readings are not a diagnosis and the system is not a certified medical device. The reference ranges, the analyte models, and the tear glucose to blood glucose mapping are all derived from published research, but the sensor signal itself is simulated for the capstone demonstration. Any value that looks unusual should be checked with a qualified doctor before acting on it. The app should not be used to decide on insulin, medication, food intake, or any other clinical action.

## Analyte glossary
- TG (tear glucose): glucose dissolved in basal tear fluid. It correlates with blood glucose trends, typically following blood glucose changes within about 10 to 15 minutes.
- Na (sodium): the primary electrolyte in tear fluid. It reflects overall tear film osmolarity and is closely tied to hydration status.
- K (potassium): present in tears at much higher levels than in blood plasma. It supports corneal epithelial cell health and ocular surface integrity.
- Cl (chloride): the main anion in tear fluid. It pairs with sodium to maintain electrical neutrality and tear film osmotic balance.
- Chol (cholesterol): lipids secreted by the meibomian glands in the eyelids. They form the outer lipid layer of the tear film and slow tear evaporation.

## Reference ranges used in SmartTear

| Analyte | Normal range | Unit | Source |
|---|---|---|---|
| Tear Glucose (TG) | 0.1 to 0.5 | mmol/L | Park et al. 2024, Nature Communications, real paired tear and blood glucose measurements |
| Sodium (Na) | 120 to 165 | mEq/L | Electrolyte biomarkers in human tears, systematic review, Asian Journal of Biological and Life Sciences, 2024 (clinical mean 131.06 ± 6.39 mmol/L across 50 subjects) |
| Potassium (K) | 20 to 42 | mEq/L | Same systematic review (clinical mean 21.40 ± 1.57 mmol/L) |
| Chloride (Cl) | 106 to 136 | mEq/L | Same systematic review (clinical mean 122.86 ± 7.12 mmol/L) |
| Cholesterol (Chol) | 0.5 to 3.0 | mmol/L | Song et al. 2022, tear cholesterol values from a wireless smart contact lens study (normal subjects roughly 1.5 to 2.5 mmol/L, elevated above 3.0 in hyperlipidemic subjects) |

The ranges are population averages from peer-reviewed literature, not personalized thresholds. Individual values can shift with time of day, hydration, and collection technique.

## What it means if a value is high or low

### Tear glucose (TG)
- High (above 0.8 mmol/L): may suggest elevated blood glucose, a post-meal spike, stress, or dehydration concentrating the tear fluid. Suggested next step: drink water, retake in 15 to 20 minutes, and mention persistently high readings to a doctor.
- Low (below 0.3 mmol/L): often points to insufficient sample volume or dilution from reflex tearing rather than a real low. Suggested next step: blink a few times, clean the tip, and retake. If readings stay low and the user feels shakiness, sweating, or confusion, check blood glucose with a certified glucometer.

### Sodium (Na)
- High (above 165 mEq/L): a strong signal of dehydration or dry eye, often linked to long screen sessions, air conditioning, contact lens wear, or high dietary salt. Suggested next step: drink water, take screen breaks using the 20-20-20 rule, and retake later.
- Low (below 120 mEq/L): rare. May suggest overhydration or altered lacrimal secretion. Suggested next step: retake to confirm before reading anything into a single value.

### Potassium (K)
- High (above 42 mEq/L): may reflect corneal stress, ocular surface inflammation, or irritation from contact lenses or allergens. Suggested next step: take a break from contact lenses, avoid eye rubbing, and see an eye doctor if irritation persists.
- Low (below 20 mEq/L): may suggest reduced lacrimal secretion or low dietary potassium. Suggested next step: retake to rule out a thin sample, then consider potassium-rich foods such as bananas, spinach, and avocado.

### Chloride (Cl)
- High (above 136 mEq/L): chloride tracks sodium, so a high chloride alongside high sodium reinforces a hyperosmolar tear film and likely dehydration. Suggested next step: hydrate and retake.
- Low (below 106 mEq/L): rare and usually mirrors a low sodium reading. Suggested next step: retake to confirm.

### Cholesterol (Chol)
- High (above 3.0 mmol/L): may indicate meibomian gland hypersecretion or systemic high cholesterol affecting gland output. Usually not harmful unless very elevated. Suggested next step: mention to a doctor if it stays high across readings, especially with other dry eye symptoms.
- Low (below 0.5 mmol/L): an insufficient lipid layer means tears evaporate faster, which can cause burning and grittiness. Suggested next step: warm eyelid compresses for about five minutes daily, gentle eyelid hygiene, and omega-3 intake.

## When to see a doctor
- Tear glucose stays high across several consecutive readings, especially alongside thirst, frequent urination, or unexplained weight change.
- Symptoms of hypoglycemia or hyperglycemia (shakiness, sweating, confusion, blurred vision) appear, regardless of what the app shows. Use a certified glucometer first and call a doctor.
- Readings keep coming back invalid after multiple retakes and the issue is not the tip or the contact technique.
- Persistent dry eye, burning, gritty feeling, redness, or pain in the eyes.
- Values swing widely between sessions without an obvious lifestyle reason.
- Any health concern the user had in mind when they decided to check.

## How readings are collected and validated
A soft sensor tip touches the eye surface briefly to absorb basal tear fluid. The device sends a packet to the app containing 8 raw sensor channels, a timestamp, device metadata, and the measured contact duration in milliseconds. The app first runs `PackageValidator` to confirm required fields and structure, then writes the raw packet to local storage before any processing so nothing is lost on failure. `Preprocessor` clips each channel to the trained scaler's min/max bounds, applies MinMax normalization, clips contact duration to the 500 to 2500 ms window, and normalizes it to [0, 1] as the ninth feature. The three TFLite models then estimate tear glucose, the three electrolytes, and cholesterol.

`QCClassifier` then evaluates three rules. A reading is marked invalid if any of these fire:
- Contact duration below 500 ms. Reason: "Contact time too short". Fix: hold the tip gently against the eye for at least one full second.
- Variance across the first five sensor channels below 0.0008. Reason: "Weak signal". Fix: blink a few times before retaking to stimulate natural tear production.
- Estimated tear glucose below 0.05 mmol/L or above 3.0 mmol/L. Reason: "Analyte value outside expected range". Fix: clean the tip and retake in a relaxed state.

Invalid readings are still stored with their reason, are excluded from history statistics by default, and can be retaken from the same screen.

## Estimated blood glucose (BG)
Estimated BG is an optional feature controlled by an `estBgEnabled` toggle in Settings. When the toggle is on, the app runs a TFLite regression model (`tg_bg_model_v1.tflite`) on the current tear glucose value to produce an estimated blood glucose in mmol/L, alongside a converted mg/dL value for convenience. The model takes three polynomial features `[TG, TG², TG³]` normalized using `scaler_tg_bg.json`, and was trained on 208 paired tear glucose and blood glucose measurements drawn from Park et al. 2024 (Nature Communications), with reported R² of about 0.82 on the human subject subset.

This is a statistical estimate, not a clinical blood glucose measurement. It should not be used to decide on insulin, food, or medication. For any decision that depends on blood glucose, use a certified glucometer.