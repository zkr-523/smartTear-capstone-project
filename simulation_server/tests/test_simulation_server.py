"""Tests for simulation_server/main.py.

Statistical determinism note (SIM-007): /reading emits short contact (200 ms) at 5%.
With n=200 reads, P(zero short contacts) = 0.95**200 ~= 3.5e-5, well under 0.01.
"""
import os
import sys
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

# Make the simulation_server/ directory importable when pytest is run from repo root.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import main as sim  # noqa: E402


@pytest.fixture(autouse=True)
def _reset_state(monkeypatch):
    sim.state["connected"] = False
    sim.state["device_id"] = None
    sim.state["last_reading_time"] = None
    # Default: no API key, so /chat returns the local fallback unless a test overrides.
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    yield


@pytest.fixture
def client():
    return TestClient(sim.app)


# --- /pair ---------------------------------------------------------------

def test_sim_001_pair_updates_state_and_echoes_device_id(client):
    resp = client.post("/pair", json={"device_id": "SIM-XYZ"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "connected"
    assert body["device_id"] == "SIM-XYZ"
    assert sim.state["connected"] is True
    assert sim.state["device_id"] == "SIM-XYZ"


def test_sim_002_pair_without_device_id_returns_422(client):
    resp = client.post("/pair", json={})
    assert resp.status_code == 422


# --- /reading ------------------------------------------------------------

def test_sim_003_reading_has_all_documented_fields(client):
    body = client.get("/reading").json()
    for key in (
        "timestamp",
        "device_id",
        "schema_version",
        "sample_status",
        "contact_duration_ms",
        "raw_channels",
    ):
        assert key in body, f"missing field {key}"


def test_sim_004_raw_channels_is_eight_floats_in_0_1(client):
    body = client.get("/reading").json()
    ch = body["raw_channels"]
    assert isinstance(ch, list)
    assert len(ch) == 8
    for v in ch:
        assert 0.0 <= float(v) <= 1.0


def test_sim_005_schema_version_is_1(client):
    body = client.get("/reading").json()
    assert body["schema_version"] == 1


def test_sim_006_sample_status_always_in_known_set(client):
    allowed = {"complete", "partial", "failed"}
    for _ in range(40):
        body = client.get("/reading").json()
        assert body["sample_status"] in allowed


def test_sim_007_short_contact_appears_in_200_reads(client):
    # P(none) = 0.95**200 ~= 3.5e-5 < 0.01 — deterministic enough for CI.
    short = 0
    for _ in range(200):
        if client.get("/reading").json()["contact_duration_ms"] < 500:
            short += 1
    assert short >= 1


# --- /status -------------------------------------------------------------

def test_sim_008_status_reflects_pair_state(client):
    assert client.get("/status").json()["connected"] is False
    client.post("/pair", json={"device_id": "SIM-1"})
    assert client.get("/status").json()["connected"] is True


# --- /chat ---------------------------------------------------------------

def test_sim_009_chat_without_api_key_returns_literal_fallback(client):
    resp = client.post("/chat", json={"message": "hi"})
    assert resp.status_code == 200
    assert "Assistant unavailable" in resp.json()["response"]


def test_sim_010_chat_with_gemini_error_returns_connection_trouble(client, monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "fake-key")

    class _BoomClient:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *a):
            return False

        async def post(self, *a, **kw):
            raise RuntimeError("network boom")

    with patch.object(sim.httpx, "AsyncClient", lambda: _BoomClient()):
        resp = client.post("/chat", json={"message": "hi"})

    assert resp.status_code == 200
    assert "trouble connecting" in resp.json()["response"].lower()


def test_sim_011_chat_with_reading_context_passes_to_gemini(client, monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "fake-key")

    captured = {}

    class _FakeResponse:
        def json(self_inner):
            return {
                "candidates": [
                    {"content": {"parts": [{"text": "Your TG is 0.9 mmol/L."}]}}
                ]
            }

    class _FakeClient:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *a):
            return False

        async def post(self, url, json=None, timeout=None):
            captured["url"] = url
            captured["body"] = json
            return _FakeResponse()

    reading_ctx = {
        "readingId": 1,
        "takenAt": "2026-05-17T10:00:00Z",
        "qcStatus": "valid",
        "analytes": [
            {"code": "TG", "value": 0.9, "unit": "mmol/L"},
            {"code": "Na", "value": 130.0, "unit": "mEq/L"},
        ],
        "contactDurationMs": 1500,
    }

    with patch.object(sim.httpx, "AsyncClient", lambda: _FakeClient()):
        resp = client.post(
            "/chat",
            json={"message": "what is my TG?", "currentReading": reading_ctx},
        )

    assert resp.status_code == 200
    assert "0.9" in resp.json()["response"]
    sys_text = captured["body"]["system_instruction"]["parts"][0]["text"]
    assert "TG 0.90 mmol/L" in sys_text
    assert "Contact 1500ms" in sys_text


# --- generate_channels / force_short ------------------------------------

def test_sim_012_generate_channels_respects_bands_with_tolerance():
    # Run many samples, check empirical channel ranges sit roughly within band ± noise+rounding tolerance.
    tol = 0.10
    accum = [[] for _ in range(8)]
    for _ in range(200):
        ch = sim.generate_channels()
        for i, v in enumerate(ch):
            accum[i].append(v)
    for i, (low, high) in enumerate(sim.CHANNEL_RANGES):
        mn = min(accum[i])
        mx = max(accum[i])
        assert mn >= max(0.0, low - tol), f"ch{i} min {mn} below band {low}"
        assert mx <= min(1.0, high + tol), f"ch{i} max {mx} above band {high}"


def test_sim_013_force_short_caps_sentences_and_strips_bold():
    raw = "**TG 0.9 mmol/L** is high. Sodium is 130. Cholesterol is 1.2. Extra sentence here."
    out = sim.force_short(raw)
    assert "**" not in out
    # No more than 3 sentences kept.
    import re as _re
    parts = [p for p in _re.split(r"(?<=[.!?])(?<!\d)\s+", out) if p.strip()]
    assert len(parts) <= 3
    assert "0.9" in out
