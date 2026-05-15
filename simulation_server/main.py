# SmartTear Simulation Server + AI Chat Assistant
#
# Deploy this file as main.py on Replit (smart-tear-simulation).
# Flutter: SimulationConnector + ChatAssistantService use the same base URL.
#
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
from typing import List, Optional
import random
import numpy as np
import os
import httpx
import re

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

# Compact facts for chat only — keeps replies short (full app copy lives in Flutter).
CHAT_KNOWLEDGE = """
SmartTear: tear biosensor capstone; ML runs on-device (TFLite).
TG (tear glucose) normal 0.30–0.85 mmol/L on-device. Na 120–165, K 20–42, Cl 106–136 mEq/L. Chol 0.5–3.0 mmol/L.
ESTIMATED BLOOD GLUCOSE: neural network trained on 208 real paired tear glucose and blood glucose
measurements from Park et al. 2024 (Nature Communications). Polynomial input from tear glucose;
R² about 0.82 for human subjects. Statistical estimate only, not a clinical measurement.
Normal blood glucose: 3.9 to 7.8 mmol/L (70 to 140 mg/dL).
QC invalid: short contact (<500ms), weak signal, or out-of-range values — suggest retake.
Not a medical diagnosis; estimates only.
"""


class PairRequest(BaseModel):
    device_id: str


class AnalyteData(BaseModel):
    code: str
    value: float
    unit: str
    estimatedBG: Optional[float] = None


class ReadingContext(BaseModel):
    readingId: int
    takenAt: str
    qcStatus: str
    invalidReason: Optional[str] = None
    analytes: List[AnalyteData]
    contactDurationMs: Optional[int] = None


class HistorySummary(BaseModel):
    totalReadings: int
    validReadings: int
    avgGlucose: Optional[float] = None
    lastReadingAt: Optional[str] = None


class ConversationTurn(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    systemPrompt: Optional[str] = None
    currentReading: Optional[ReadingContext] = None
    history: Optional[HistorySummary] = None
    conversationHistory: Optional[List[ConversationTurn]] = None


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


MAX_CHAT_SENTENCES = 3
MAX_CHAT_CHARS = 400


def force_short(text: str, max_sentences: int = MAX_CHAT_SENTENCES) -> str:
    """Strip markdown and cap length without cutting mid-sentence or decimals."""
    text = re.sub(r"\*\*(.+?)\*\*", r"\1", text)
    text = re.sub(r"\*(.+?)\*", r"\1", text)
    text = re.sub(r"#{1,6}\s+", "", text)
    text = re.sub(r"^\s*[-•*]\s+", "", text, flags=re.MULTILINE)
    text = re.sub(r"^\s*\d+\.\s+", "", text, flags=re.MULTILINE)
    text = re.sub(r"\n{2,}", " ", text)
    text = re.sub(r"\s+", " ", text).strip()

    # Do not split on decimals (e.g. 0.9 mmol/L)
    parts = re.split(r"(?<=[.!?])(?<!\d)\s+", text)
    parts = [p.strip() for p in parts if p.strip()]

    if len(parts) > max_sentences:
        parts = parts[:max_sentences]

    out = " ".join(parts)
    if len(out) > MAX_CHAT_CHARS:
        kept = []
        for p in parts:
            candidate = " ".join(kept + [p])
            if len(candidate) > MAX_CHAT_CHARS:
                break
            kept.append(p)
        out = " ".join(kept) if kept else out[:MAX_CHAT_CHARS].rsplit(" ", 1)[0].strip()

    if out and out[-1] not in ".?!":
        out += "."
    return out


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


@app.post("/chat")
async def chat(request: ChatRequest):
    api_key = os.environ.get("GEMINI_API_KEY", "")

    if not api_key:
        return {"response": "Assistant unavailable. API key not configured."}

    reading_ctx = "No reading selected."
    if request.currentReading:
        r = request.currentReading
        valid_analytes = [a for a in r.analytes if a.value is not None]
        if valid_analytes:
            analyte_lines = ", ".join(
                f"{a.code} {a.value:.2f} {a.unit}"
                + (f" Est BG {a.estimatedBG:.1f}" if a.estimatedBG else "")
                for a in valid_analytes
            )
        else:
            analyte_lines = "no analyte values available"

        status_line = r.qcStatus.upper()
        if r.invalidReason:
            status_line += f" reason {r.invalidReason}"

        reading_ctx = (
            f"Reading taken at {r.takenAt}. "
            f"Status {status_line}. "
            f"Values: {analyte_lines}."
            + (f" Contact {r.contactDurationMs}ms." if r.contactDurationMs else "")
        )

    history_ctx = "No history yet."
    if request.history:
        h = request.history
        avg = f"{h.avgGlucose:.2f} mmol/L" if h.avgGlucose else "unknown"
        history_ctx = (
            f"User has {h.totalReadings} readings, "
            f"{h.validReadings} valid, "
            f"avg glucose {avg}."
        )

    client_addendum = (request.systemPrompt or "").strip()

    system_prompt = f"""You are ZKR, the SmartTear in-app assistant.

LENGTH:
At most {MAX_CHAT_SENTENCES} complete sentences, under {MAX_CHAT_CHARS} characters total.
Plain text only — no markdown, bullets, or lists.
Always include the analyte name AND the numeric value with units (e.g. TG 0.9 mmol/L).
Never write "is ." or leave a value blank — finish every thought.
Sound like a helpful text message, not an essay.

CONVERSATION:
Use READING and the message history for context and follow-ups.
Do not re-introduce yourself every turn.
If useful, end with one short follow-up question (still within 2 sentences).

FACTS:
{CHAT_KNOWLEDGE}

READING:
{reading_ctx}

HISTORY:
{history_ctx}
"""

    if client_addendum:
        system_prompt += (
            f"\nAPP (length limits above still win):\n{client_addendum}\n"
        )

    system_prompt += """
EXAMPLES:
hi → Hey! Attach a reading with the book icon, or ask me about your last result.
what does TG 0.38 mean → Your tear glucose (TG) is 0.38 mmol/L, in the normal 0.30–0.85 band. Want to compare it to your trend?
which analyte is most affected → Tear glucose (TG) at 0.9 mmol/L is high versus the 0.30–0.85 band. Sodium and cholesterol look OK on this reading.
why invalid → Contact was likely too short or the signal weak — try a longer hold and blink first. Retake?"""

    messages = []
    if request.conversationHistory:
        for turn in request.conversationHistory[-6:]:
            role = "user" if turn.role == "user" else "model"
            messages.append({"role": role, "parts": [{"text": turn.content}]})

    messages.append({"role": "user", "parts": [{"text": request.message}]})

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}",
                json={
                    "system_instruction": {"parts": [{"text": system_prompt}]},
                    "contents": messages,
                    "generationConfig": {
                        "maxOutputTokens": 180,
                        "temperature": 0.45,
                    },
                },
                timeout=15.0,
            )
            data = response.json()
            raw_text = data["candidates"][0]["content"]["parts"][0]["text"]
            final = force_short(raw_text)
            return {"response": final}

    except Exception as e:
        print(f"Chat error: {e}")
        return {"response": "Having trouble connecting. Please try again."}


if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 3000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
