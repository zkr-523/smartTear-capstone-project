# Channel Map (matches ml_training step1 + Flutter rawChannels[0..7]):
#   channel[0] — tear_glucose proxy     (0.06 – 0.90)
#   channel[1] — sodium proxy           (0.5 – 0.75)
#   channel[2] — potassium proxy        (0.3 – 0.60)
#   channel[3] — chloride proxy         (0.4 – 0.70)
#   channel[4] — cholesterol proxy      (0.2 – 0.50)
#   channel[5] — pH proxy               (0.45 – 0.65)
#   channel[6] — temperature proxy      (0.48 – 0.55)
#   channel[7] — noise channel          (0.0 – 0.15)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime, timezone
import random
import numpy as np
import os

app = FastAPI(title="SmartTear Simulation Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

state = {
    "connected": False,
    "device_id": None,
    "last_reading_time": None,
}

# ch0 upper bound 0.90 aligns with Park/ML training proxy scale (delta_I/I0 / 62)
CHANNEL_RANGES = [
    (0.06, 0.90),
    (0.50, 0.75),
    (0.30, 0.60),
    (0.40, 0.70),
    (0.20, 0.50),
    (0.45, 0.65),
    (0.48, 0.55),
    (0.00, 0.15),
]
NOISE_STD = 0.02


class PairRequest(BaseModel):
    device_id: str


def _sample_tg_ch0_proxy() -> float:
    """
    ch0 tuned to glucose_model_v1.tflite output bands (app: 0.30–0.85 mmol/L).
    Target mix: ~65% NORMAL, ~20% HIGH, ~15% LOW for new readings.
    """
    r = random.random()
    if r < 0.65:
        return random.uniform(0.08, 0.17)
    if r < 0.85:
        return random.uniform(0.20, 0.26)
    return random.uniform(0.04, 0.065)


def generate_channels() -> list:
    channels = []
    for i, (low, high) in enumerate(CHANNEL_RANGES):
        if i == 0:
            base = _sample_tg_ch0_proxy()
        else:
            base = random.uniform(low, high)
        noisy = base + np.random.normal(0, NOISE_STD)
        clamped = round(float(np.clip(noisy, 0.0, 1.0)), 4)
        channels.append(clamped)
    return channels


@app.post("/pair")
def pair(request: PairRequest):
    state["connected"] = True
    state["device_id"] = request.device_id
    return {
        "status": "connected",
        "device_id": request.device_id,
        "firmware": "1.0.0",
    }


@app.get("/reading")
def get_reading():
    now = datetime.now(timezone.utc).isoformat()
    state["last_reading_time"] = now

    if random.random() < 0.05:
        contact_duration_ms = 200
    else:
        contact_duration_ms = random.randint(800, 2500)

    roll = random.random()
    if roll < 0.05:
        sample_status = "failed"
    elif roll < 0.15:
        sample_status = "partial"
    else:
        sample_status = "complete"

    return {
        "timestamp": now,
        "device_id": state["device_id"] or "SIM-001",
        "schema_version": 1,
        "sample_status": sample_status,
        "contact_duration_ms": contact_duration_ms,
        "raw_channels": generate_channels(),
    }


@app.get("/status")
def get_status():
    return {
        "connected": state["connected"],
        "device_id": state["device_id"] or "SIM-001",
        "last_reading": state["last_reading_time"],
    }


if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 3000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
