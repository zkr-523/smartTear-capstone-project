# SmartTear — Step 3: Train the three analyte estimation models
# Run after build_features.py
# Produces: saved_models/ directory with 3 .keras model files

import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import math
import os

os.makedirs('saved_models', exist_ok=True)
tf.random.set_seed(42)

df = pd.read_csv('features.csv')
X = df[[f'f{i}' for i in range(9)]].values

# ── Model 1: Glucose ──────────────────────────────────────────────────────────
print("=" * 50)
print("Training Model 1: Glucose")
y_glucose = df['glucose_mmol'].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y_glucose, test_size=0.2, random_state=42)

glucose_model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(9,)),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(8,  activation='relu'),
    tf.keras.layers.Dense(1,  activation='linear'),
], name='glucose_model')

glucose_model.compile(optimizer='adam', loss='mse')
glucose_model.fit(X_train, y_train, epochs=100, batch_size=32,
                  validation_split=0.1, verbose=0)

pred = glucose_model.predict(X_test, verbose=0).flatten()
rmse = math.sqrt(mean_squared_error(y_test, pred))
print(f"  Glucose RMSE: {rmse:.4f} mmol/L")
glucose_model.save('saved_models/glucose_model.keras')

# ── Model 2: Electrolytes ─────────────────────────────────────────────────────
print("Training Model 2: Electrolytes (Na, K, Cl)")
y_elec = df[['sodium_meq', 'potassium_meq', 'chloride_meq']].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y_elec, test_size=0.2, random_state=42)

elec_model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(9,)),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(8,  activation='relu'),
    tf.keras.layers.Dense(3,  activation='linear'),
], name='electrolytes_model')

elec_model.compile(optimizer='adam', loss='mse')
elec_model.fit(X_train, y_train, epochs=100, batch_size=32,
               validation_split=0.1, verbose=0)

pred = elec_model.predict(X_test, verbose=0)
rmse_na  = math.sqrt(mean_squared_error(y_test[:,0], pred[:,0]))
rmse_k   = math.sqrt(mean_squared_error(y_test[:,1], pred[:,1]))
rmse_cl  = math.sqrt(mean_squared_error(y_test[:,2], pred[:,2]))
print(f"  Na RMSE: {rmse_na:.4f} mEq/L")
print(f"  K  RMSE: {rmse_k:.4f}  mEq/L")
print(f"  Cl RMSE: {rmse_cl:.4f} mEq/L")
elec_model.save('saved_models/electrolytes_model.keras')

# ── Model 3: Cholesterol ──────────────────────────────────────────────────────
print("Training Model 3: Cholesterol")
y_chol = df['cholesterol'].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y_chol, test_size=0.2, random_state=42)

chol_model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(9,)),
    tf.keras.layers.Dense(8, activation='relu'),
    tf.keras.layers.Dense(1, activation='linear'),
], name='cholesterol_model')

chol_model.compile(optimizer='adam', loss='mse')
chol_model.fit(X_train, y_train, epochs=100, batch_size=32,
               validation_split=0.1, verbose=0)

pred = chol_model.predict(X_test, verbose=0).flatten()
rmse = math.sqrt(mean_squared_error(y_test, pred))
print(f"  Cholesterol RMSE: {rmse:.4f} mmol/L")
chol_model.save('saved_models/cholesterol_model.keras')

print("\nAll models trained and saved to saved_models/")

