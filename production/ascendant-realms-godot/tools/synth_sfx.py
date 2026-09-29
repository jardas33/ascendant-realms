"""Procedural UI sound effects for Ascendant Realms (no external assets, free).
Writes 16-bit mono 44.1 kHz WAVs into assets/audio/sfx/ui/."""
import math, random, struct, wave, os

SR = 44100
OUT = 'D:/ClaudeWork/ar-lane/production/ascendant-realms-godot/assets/audio/sfx/ui'
random.seed(77)

def write(name, samples):
    peak = max(1e-6, max(abs(s) for s in samples))
    gain = 0.85 / peak
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s * gain)) * 32767)) for s in samples))

def env(t, a, d):
    """Attack then exponential decay."""
    return (t / a) if t < a else math.exp(-(t - a) / d)

def lowpass(xs, k):
    out, y = [], 0.0
    for x in xs:
        y += k * (x - y); out.append(y)
    return out

# 1. Hover tick: a tiny bright wooden tap.
n = int(SR * 0.06)
write('ui_hover_tick.wav', [math.sin(2 * math.pi * 2400 * i / SR) * env(i / SR, 0.001, 0.008) * 0.5
                            + math.sin(2 * math.pi * 1200 * i / SR) * env(i / SR, 0.001, 0.012) * 0.5 for i in range(n)])

# 2. Coin chime: two bell partials, a bright gold ring (jars, caravan, loot).
n = int(SR * 0.9)
def bell(f, t, d):
    return (math.sin(2 * math.pi * f * t) + 0.5 * math.sin(2 * math.pi * f * 2.76 * t) + 0.25 * math.sin(2 * math.pi * f * 5.4 * t)) * env(t, 0.002, d)
write('ui_coin_chime.wav', [bell(1318.5, i / SR, 0.25) + 0.8 * bell(1760.0, max(0.0, i / SR - 0.07), 0.3) * (1 if i / SR > 0.07 else 0) for i in range(n)])

# 3. Seal stamp: a low thump with a short wax slap.
n = int(SR * 0.5)
noise = lowpass([random.uniform(-1, 1) for _ in range(n)], 0.08)
write('ui_seal_stamp.wav', [math.sin(2 * math.pi * (70 + 60 * math.exp(-i / SR / 0.03)) * i / SR) * env(i / SR, 0.002, 0.12)
                            + noise[i] * 1.6 * env(i / SR, 0.001, 0.03) for i in range(n)])

# 4. Page turn: filtered noise swish rising and falling (briefings, chronicle).
n = int(SR * 0.35)
noise = [random.uniform(-1, 1) for _ in range(n)]
hp = []
prev = 0.0
for x in lowpass(noise, 0.35):
    hp.append(x - prev * 0.6); prev = x
write('ui_page_turn.wav', [hp[i] * math.sin(math.pi * min(1.0, i / n)) ** 2 for i in range(n)])

# 5. War horn: a short brass call for battle start and victory.
n = int(SR * 1.4)
def horn(t):
    f = 220.0 * (1.0 + 0.02 * math.sin(2 * math.pi * 5 * t) * min(1.0, t * 2))
    s = sum(math.sin(2 * math.pi * f * k * t) / k ** 1.3 for k in range(1, 9))
    a = min(1.0, t / 0.12) * (1.0 if t < 1.0 else max(0.0, 1.0 - (t - 1.0) / 0.4))
    return s * a
write('ui_war_horn.wav', lowpass([horn(i / SR) for i in range(n)], 0.25))

# 6. Order acknowledgement: a soft wooden double knock.
n = int(SR * 0.18)
write('ui_order_knock.wav', [sum(math.sin(2 * math.pi * f * max(0.0, i / SR - o)) * env(max(0.0, i / SR - o), 0.001, 0.02) * (1 if i / SR >= o else 0)
                                  for f, o in [(520, 0.0), (430, 0.07)]) for i in range(n)])
print('ok')
