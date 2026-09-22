#!/usr/bin/env python3
"""Deterministically synthesize the project's original, dry projectile-impact cue.

Uses only Python's standard library for audio generation; no samples or network.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 48_000
DURATION_SECONDS = 0.18
SEED = 730_1001
TARGET_PEAK = 0.72


def synthesize() -> list[float]:
    rng = random.Random(SEED)
    samples: list[float] = []
    previous_noise = 0.0
    low_noise = 0.0
    frame_count = round(SAMPLE_RATE * DURATION_SECONDS)

    for index in range(frame_count):
        time_s = index / SAMPLE_RATE
        noise = rng.uniform(-1.0, 1.0)
        high_pass_noise = noise - previous_noise
        previous_noise = noise
        low_noise += 0.18 * (noise - low_noise)

        # Revision 2: a dry contact transient and short noise-shaped body thock;
        # waveform review rejected the first draft's overly tonal decay.
        transient_env = math.exp(-time_s / 0.0015) * max(0.0, 1.0 - time_s / 0.007)
        texture_env = math.exp(-time_s / 0.018) * max(0.0, 1.0 - time_s / 0.075)
        body = 0.20 * low_noise * texture_env
        body += 0.075 * math.sin(2.0 * math.pi * 112.0 * time_s) * math.exp(-time_s / 0.014)
        contact = 0.24 * high_pass_noise * transient_env + 0.075 * noise * texture_env

        # Remove the last few milliseconds smoothly; the overall cue stays short and dry.
        end_env = min(1.0, max(0.0, (DURATION_SECONDS - time_s) / 0.018))
        samples.append((body + contact) * end_env)

    mean = sum(samples) / len(samples)
    samples = [sample - mean for sample in samples]
    peak = max(abs(sample) for sample in samples)
    if peak == 0.0:
        raise RuntimeError("synthesis unexpectedly produced silence")
    scale = TARGET_PEAK / peak
    return [sample * scale for sample in samples]


def quantize(samples: list[float]) -> list[int]:
    return [max(-32768, min(32767, round(sample * 32767.0))) for sample in samples]


def metrics(samples: list[float], pcm: list[int], wav_bytes: bytes) -> dict[str, object]:
    peak = max(abs(sample) for sample in samples)
    rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
    dc_offset = sum(pcm) / (len(pcm) * 32768.0)
    return {
        "sample_rate_hz": SAMPLE_RATE,
        "channels": 1,
        "bit_depth": 16,
        "codec": "PCM signed 16-bit little-endian WAV",
        "duration_seconds": len(samples) / SAMPLE_RATE,
        "peak_linear": peak,
        "peak_dbfs": 20.0 * math.log10(peak),
        "rms_linear": rms,
        "rms_dbfs": 20.0 * math.log10(rms),
        "dc_offset_linear": dc_offset,
        "clipped_sample_count": sum(value in (-32768, 32767) for value in pcm),
        "sha256": hashlib.sha256(wav_bytes).hexdigest(),
        "seed": SEED,
        "target_peak": TARGET_PEAK,
    }


def write_waveform(path: Path, pcm: list[int]) -> None:
    from PIL import Image, ImageDraw

    width, height = 1200, 360
    image = Image.new("RGB", (width, height), "#10151b")
    draw = ImageDraw.Draw(image)
    mid = height // 2
    draw.line((32, mid, width - 24, mid), fill="#46525e", width=1)
    draw.line((32, 30, 32, height - 28), fill="#46525e", width=1)
    draw.text((38, 12), "Original projectile impact | 48 kHz mono PCM16 | 0.20 s", fill="#d6e1e8")
    envelope = 32767
    for x in range(32, width - 24):
        left = (x - 32) * len(pcm) // (width - 56)
        right = max(left + 1, (x - 31) * len(pcm) // (width - 56))
        block = pcm[left:right]
        high = max(block) / envelope
        low = min(block) / envelope
        y_top = round(mid - high * (height * 0.40))
        y_bottom = round(mid - low * (height * 0.40))
        draw.line((x, y_top, x, y_bottom), fill="#74d3b2", width=1)
    image.save(path)


def render_wav(samples: list[float]) -> tuple[bytes, list[int]]:
    pcm = quantize(samples)
    frame_data = b"".join(struct.pack("<h", sample) for sample in pcm)
    import io

    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(frame_data)
    return buffer.getvalue(), pcm


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="production/ascendant-realms-godot/assets/audio/sfx/combat/combat_projectile_impact.wav",
    )
    parser.add_argument("--waveform", help="Optional PNG waveform evidence path (requires existing Pillow)")
    args = parser.parse_args()

    samples = synthesize()
    wav_bytes, pcm = render_wav(samples)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(wav_bytes)
    result = metrics(samples, pcm, wav_bytes)
    result["output"] = str(output_path)
    if args.waveform:
        waveform_path = Path(args.waveform)
        waveform_path.parent.mkdir(parents=True, exist_ok=True)
        write_waveform(waveform_path, pcm)
        result["waveform"] = str(waveform_path)
    print(json.dumps(result, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()
