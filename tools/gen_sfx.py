#!/usr/bin/env python3
import math
import os
import random
import struct
import wave

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")


def write_wav(name: str, samples: list[float]) -> None:
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, f"{name}.wav")
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples
        )
        w.writeframes(frames)


def env(i: int, n: int, attack: int = 80, release: int = 400) -> float:
    a = min(1.0, i / attack)
    r = min(1.0, (n - i) / release)
    return a * r


def tone(freq: float, dur: float, vol: float = 0.28) -> list[float]:
    n = int(SR * dur)
    return [math.sin(2 * math.pi * freq * i / SR) * vol * env(i, n) for i in range(n)]


def noise(dur: float, vol: float = 0.18, low: bool = False) -> list[float]:
    n = int(SR * dur)
    acc = 0.0
    out = []
    for i in range(n):
        acc = acc * 0.92 + (random.random() * 2 - 1) * 0.08 if low else (random.random() * 2 - 1)
        out.append(acc * vol * env(i, n, 200, 1200))
    return out


write_wav("cargar", tone(420, 0.12, 0.22) + tone(640, 0.08, 0.16))
write_wav("soltar", tone(220, 0.14, 0.2))
write_wav("depositar", tone(160, 0.18, 0.24) + tone(240, 0.12, 0.14))
write_wav("descanso", tone(90, 0.4, 0.16) + tone(120, 0.3, 0.1))
write_wav("paso", tone(90, 0.05, 0.08))
write_wav("viento", noise(3.2, 0.12, True))
print("sfx written", OUT)
