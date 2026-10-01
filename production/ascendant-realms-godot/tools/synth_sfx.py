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
# 7. Collapse: a deep rumble with falling timber and stone crackle (a building falls).
n = int(SR * 1.6)
rough = lowpass([random.uniform(-1, 1) for _ in range(n)], 0.03)
crackle = [random.uniform(-1, 1) if random.random() < 0.02 + 0.1 * math.exp(-i / SR / 0.25) else 0.0 for i in range(n)]
crackle = lowpass(crackle, 0.5)
write('ui_collapse.wav', [rough[i] * 3.0 * env(i / SR, 0.02, 0.5)
                          + math.sin(2 * math.pi * (48 + 20 * math.exp(-i / SR / 0.2)) * i / SR) * 0.6 * env(i / SR, 0.01, 0.35)
                          + crackle[i] * 1.2 * env(i / SR, 0.05, 0.6) for i in range(n)])
print('ok')


# ---------------------------------------------------------------------------
# Plan 86: a wider palette. Gathering was silent, every melee hit and every
# spell shared one sound, and a refused order made none.
# ---------------------------------------------------------------------------
COMBAT = OUT.replace('/ui', '/combat')
random.seed(86)

def write_to(folder, name, samples, level=0.8):
    peak = max(1e-6, max(abs(s) for s in samples))
    gain = level / peak
    # 5 ms fade at both ends so nothing clicks.
    f = int(SR * 0.005)
    n = len(samples)
    with wave.open(os.path.join(folder, name), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        out = []
        for i, s in enumerate(samples):
            edge = min(1.0, i / f, (n - 1 - i) / f)
            out.append(struct.pack('<h', int(max(-1, min(1, s * gain * edge)) * 32767)))
        w.writeframes(b''.join(out))

def sweep(f0, f1, t, dur):
    """Phase of a sine sliding from f0 to f1 over dur seconds, at time t."""
    k = min(1.0, t / dur)
    return 2 * math.pi * (f0 * t + (f1 - f0) * t * k / 2)

def white(n):
    return [random.uniform(-1, 1) for _ in range(n)]

def highpass(xs, k):
    lp = lowpass(xs, k)
    return [x - l for x, l in zip(xs, lp)]

def at(t, start):
    """Time since `start`, or None before it."""
    return t - start if t >= start else None

# 8. Blunt hit: a dull heavy thud (hammers, mauls, fists).
n = int(SR * 0.22)
ns = lowpass(white(n), 0.12)
write_to(COMBAT, 'combat_blunt_hit.wav', [math.sin(sweep(130, 62, i / SR, 0.12)) * env(i / SR, 0.002, 0.05)
                                          + ns[i] * 1.2 * env(i / SR, 0.001, 0.02) for i in range(n)])

# 9. Siege launch: a rope twang over a wooden thump (ballista, mortar).
n = int(SR * 0.55)
ns = lowpass(white(n), 0.2)
write_to(COMBAT, 'combat_siege_launch.wav', [math.sin(2 * math.pi * 165 * (i / SR) + 3.0 * math.sin(2 * math.pi * 22 * i / SR) * math.exp(-i / SR / 0.12)) * env(i / SR, 0.002, 0.16) * 0.7
                                             + math.sin(sweep(90, 55, i / SR, 0.1)) * env(i / SR, 0.002, 0.06)
                                             + ns[i] * 0.9 * env(i / SR, 0.001, 0.03) for i in range(n)])

# 10. Arcane zap: a falling crackle of light (warlocks, obelisks, spitters).
n = int(SR * 0.3)
ns = highpass(white(n), 0.3)
write_to(COMBAT, 'combat_arcane_zap.wav', [(math.sin(sweep(1700, 620, i / SR, 0.22)) + 0.6 * math.sin(sweep(2290, 830, i / SR, 0.22)))
                                           * (0.6 + 0.4 * math.sin(2 * math.pi * 55 * i / SR)) * env(i / SR, 0.003, 0.09)
                                           + ns[i] * 0.35 * env(i / SR, 0.001, 0.02) for i in range(n)], 0.6)

# 11. Healing spell: three soft bells climbing.
n = int(SR * 1.1)
def soft_bell(f, t, d):
    return (math.sin(2 * math.pi * f * t) + 0.35 * math.sin(2 * math.pi * f * 2.0 * t) + 0.15 * math.sin(2 * math.pi * f * 3.01 * t)) * env(t, 0.006, d)
def heal(t):
    s = 0.0
    for f, st in [(523.3, 0.0), (659.3, 0.09), (784.0, 0.18), (1046.5, 0.3)]:
        dt = at(t, st)
        if dt is not None:
            s += soft_bell(f, dt, 0.28)
    return s
write_to(COMBAT, 'spell_heal.wav', [heal(i / SR) for i in range(n)], 0.6)

# 12. Quake: the ground growls and settles.
n = int(SR * 1.2)
rumble = lowpass(lowpass(white(n), 0.03), 0.03)
write_to(COMBAT, 'spell_quake.wav', [rumble[i] * 9.0 * env(i / SR, 0.03, 0.4)
                                     + math.sin(sweep(58, 38, i / SR, 0.8)) * env(i / SR, 0.01, 0.35) * 0.9 for i in range(n)])

# 13. Summoning: a breath of air drawn in, then a low bell.
n = int(SR * 0.95)
air = highpass(lowpass(white(n), 0.25), 0.05)
def summon(i):
    t = i / SR
    s = air[i] * 1.3 * (math.sin(math.pi * min(1.0, t / 0.45)) ** 2 if t < 0.45 else 0.0)
    dt = at(t, 0.32)
    if dt is not None:
        s += soft_bell(196.0, dt, 0.3) * 0.9
    return s
write_to(COMBAT, 'spell_summon.wav', [summon(i) for i in range(n)], 0.65)

# 14. Ward: a shield-rim clang with a short shimmer.
n = int(SR * 0.75)
write_to(COMBAT, 'spell_ward.wav', [sum(math.sin(2 * math.pi * f * i / SR) * a * env(i / SR, 0.001, d)
                                        for f, a, d in [(780, 1.0, 0.16), (1265, 0.6, 0.12), (1930, 0.4, 0.09), (2615, 0.25, 0.06)]) for i in range(n)], 0.55)

# 15. Fury: two war-drum beats.
n = int(SR * 0.6)
ns = lowpass(white(n), 0.15)
def drum(t):
    return math.sin(sweep(118, 60, t, 0.14)) * env(t, 0.002, 0.09)
def fury(i):
    t = i / SR
    s = drum(t) + ns[i] * 0.8 * env(t, 0.001, 0.02)
    dt = at(t, 0.17)
    if dt is not None:
        s += drum(dt) * 1.15 + ns[i] * 0.8 * env(dt, 0.001, 0.02)
    return s
write_to(COMBAT, 'spell_fury.wav', [fury(i) for i in range(n)])

# 16. Rain of missiles: three falling whistles.
n = int(SR * 0.9)
def rain(t):
    s = 0.0
    for st in [0.0, 0.17, 0.34]:
        dt = at(t, st)
        if dt is not None and dt < 0.4:
            s += math.sin(sweep(2300, 900, dt, 0.32)) * math.sin(math.pi * dt / 0.4) ** 2
    return s
write_to(COMBAT, 'spell_rain.wav', [rain(i / SR) for i in range(n)], 0.45)

# 17. Curse: two close notes sinking together.
n = int(SR * 0.95)
write_to(COMBAT, 'spell_curse.wav', [(math.sin(sweep(233, 205, i / SR, 0.9)) + math.sin(sweep(247, 217, i / SR, 0.9)) + 0.4 * math.sin(sweep(466, 410, i / SR, 0.9)))
                                     * env(i / SR, 0.04, 0.32) for i in range(n)], 0.55)

# 18-20. Work sounds: an axe in timber, a pick on stone, a sickle in the field.
n = int(SR * 0.14)
ns = lowpass(white(n), 0.3)
write_to(COMBAT, 'work_chop.wav', [math.sin(2 * math.pi * 310 * i / SR) * env(i / SR, 0.001, 0.018) + ns[i] * 1.1 * env(i / SR, 0.0005, 0.012) for i in range(n)], 0.7)
n = int(SR * 0.16)
ns = highpass(white(n), 0.4)
write_to(COMBAT, 'work_pick.wav', [(math.sin(2 * math.pi * 2150 * i / SR) + 0.6 * math.sin(2 * math.pi * 3080 * i / SR)) * env(i / SR, 0.0005, 0.02)
                                   + ns[i] * 0.5 * env(i / SR, 0.0005, 0.008) for i in range(n)], 0.5)
n = int(SR * 0.2)
ns = highpass(lowpass(white(n), 0.22), 0.2)
write_to(COMBAT, 'work_harvest.wav', [ns[i] * math.sin(math.pi * i / n) ** 2 for i in range(n)], 0.45)

# 21. Research done: two bright bells, a fifth apart.
n = int(SR * 0.85)
def research(t):
    s = soft_bell(659.3, t, 0.22)
    dt = at(t, 0.12)
    if dt is not None:
        s += soft_bell(987.8, dt, 0.3)
    return s
write_to(OUT, 'ui_research_done.wav', [research(i / SR) for i in range(n)], 0.6)

# 22. A new Age: three rising brass notes, the last one held.
n = int(SR * 1.6)
def brass(f, t, hold):
    if t < 0 or t > hold + 0.3:
        return 0.0
    a = min(1.0, t / 0.05) * (1.0 if t < hold else max(0.0, 1.0 - (t - hold) / 0.3))
    return sum(math.sin(2 * math.pi * f * k * t) / k ** 1.4 for k in range(1, 8)) * a
write_to(OUT, 'ui_age_up.wav', lowpass([brass(220.0, i / SR, 0.22) + brass(277.2, i / SR - 0.24, 0.22) + brass(329.6, i / SR - 0.48, 0.7) for i in range(n)], 0.3), 0.7)

# 23. Refused order: two short low taps (cannot afford, cannot build here).
n = int(SR * 0.24)
def refuse(t):
    s = 0.0
    for st in [0.0, 0.11]:
        dt = at(t, st)
        if dt is not None:
            s += (math.sin(2 * math.pi * 170 * dt) + 0.4 * math.sin(2 * math.pi * 340 * dt)) * env(dt, 0.003, 0.03)
    return s
write_to(OUT, 'ui_refuse.wav', [refuse(i / SR) for i in range(n)], 0.5)
print('plan 86 sounds written')
