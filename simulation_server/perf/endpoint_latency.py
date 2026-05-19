"""Endpoint latency benchmark for simulation_server/main.py.

Runs 500 measured calls per endpoint (50-call warmup) using FastAPI TestClient.
Patches httpx.AsyncClient so /chat never touches the network. GEMINI_API_KEY is
unset to exercise the safe local-fallback path.
"""
import os
import statistics
import sys
import time
from pathlib import Path
from unittest.mock import patch

from fastapi.testclient import TestClient

# Make simulation_server/ importable when running from anywhere.
_HERE = Path(__file__).resolve()
sys.path.insert(0, str(_HERE.parents[1]))

import main as sim  # noqa: E402

WARMUP = 50
ITERS = 500


def reset_state():
    sim.state["connected"] = False
    sim.state["device_id"] = None
    sim.state["last_reading_time"] = None
    os.environ.pop("GEMINI_API_KEY", None)


class _FakeResponse:
    def json(self):
        return {
            "candidates": [
                {"content": {"parts": [{"text": "ok"}]}}
            ]
        }


class _FakeClient:
    async def __aenter__(self):
        return self

    async def __aexit__(self, *a):
        return False

    async def post(self, url, json=None, timeout=None):
        return _FakeResponse()


def _pct(sorted_vals, p):
    if not sorted_vals:
        return float("nan")
    idx = int(round((len(sorted_vals) - 1) * p))
    return sorted_vals[idx]


def bench(label, call_fn):
    reset_state()
    # Warmup
    for _ in range(WARMUP):
        call_fn()
    # Measured
    samples = []
    for _ in range(ITERS):
        t0 = time.perf_counter()
        call_fn()
        t1 = time.perf_counter()
        samples.append((t1 - t0) * 1000.0)
    samples_sorted = sorted(samples)
    p50 = _pct(samples_sorted, 0.50)
    p95 = _pct(samples_sorted, 0.95)
    mx = samples_sorted[-1]
    mean = statistics.fmean(samples)
    print(f"{label}")
    print(f"  iterations: {ITERS}")
    print(f"  warmup: {WARMUP}")
    print(f"  p50_ms: {p50:.4f}")
    print(f"  p95_ms: {p95:.4f}")
    print(f"  max_ms: {mx:.4f}")
    print(f"  mean_ms: {mean:.4f}")
    print()


def main():
    client = TestClient(sim.app)

    print("=== Endpoint latency benchmark ===")
    print(f"iterations_per_endpoint: {ITERS}")
    print(f"warmup_per_endpoint: {WARMUP}")
    print()

    bench("GET /reading", lambda: client.get("/reading"))
    bench("GET /status", lambda: client.get("/status"))
    bench(
        "POST /pair",
        lambda: client.post("/pair", json={"device_id": "PERF-001"}),
    )

    # /chat with no API key — fallback path; patch httpx as belt-and-suspenders.
    with patch.object(sim.httpx, "AsyncClient", lambda: _FakeClient()):
        bench(
            "POST /chat (no API key)",
            lambda: client.post("/chat", json={"message": "hi"}),
        )


if __name__ == "__main__":
    main()
