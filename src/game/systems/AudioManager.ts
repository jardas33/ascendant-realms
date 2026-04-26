import { DEFAULT_SETTINGS } from "../core/Settings";
import type { SaveSettingsData } from "../save/SaveTypes";

export type AudioCueId =
  | "ui_click"
  | "unit_selected"
  | "build_started"
  | "build_complete"
  | "unit_trained"
  | "ability_cast"
  | "victory"
  | "defeat";

const CUE_SETTINGS: Record<AudioCueId, { frequency: number; duration: number; type?: OscillatorType; gain?: number }> = {
  ui_click: { frequency: 440, duration: 0.045, type: "triangle", gain: 0.18 },
  unit_selected: { frequency: 660, duration: 0.06, type: "sine", gain: 0.14 },
  build_started: { frequency: 220, duration: 0.09, type: "square", gain: 0.1 },
  build_complete: { frequency: 523, duration: 0.14, type: "triangle", gain: 0.16 },
  unit_trained: { frequency: 587, duration: 0.09, type: "triangle", gain: 0.14 },
  ability_cast: { frequency: 784, duration: 0.12, type: "sawtooth", gain: 0.08 },
  victory: { frequency: 880, duration: 0.22, type: "triangle", gain: 0.18 },
  defeat: { frequency: 196, duration: 0.24, type: "sine", gain: 0.18 }
};

export class AudioManager {
  private static settings: SaveSettingsData = DEFAULT_SETTINGS;
  private static context?: AudioContext;

  static configure(settings: SaveSettingsData): void {
    AudioManager.settings = settings;
  }

  static play(cueId: AudioCueId): void {
    const cue = CUE_SETTINGS[cueId];
    const volume = AudioManager.settings.masterVolume * AudioManager.settings.sfxVolume * (cue.gain ?? 0.12);
    if (!cue || volume <= 0) {
      return;
    }

    try {
      const context = AudioManager.getContext();
      if (!context) {
        return;
      }
      const oscillator = context.createOscillator();
      const gain = context.createGain();
      const now = context.currentTime;
      oscillator.type = cue.type ?? "sine";
      oscillator.frequency.setValueAtTime(cue.frequency, now);
      gain.gain.setValueAtTime(0.0001, now);
      gain.gain.exponentialRampToValueAtTime(Math.max(0.0001, volume), now + 0.01);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + cue.duration);
      oscillator.connect(gain);
      gain.connect(context.destination);
      oscillator.start(now);
      oscillator.stop(now + cue.duration + 0.02);
    } catch {
      // Audio is a feel layer. Browsers, tests, and muted devices may deny it safely.
    }
  }

  private static getContext(): AudioContext | undefined {
    if (AudioManager.context) {
      void AudioManager.context.resume?.();
      return AudioManager.context;
    }
    const audioGlobal = globalThis as typeof globalThis & { webkitAudioContext?: typeof AudioContext };
    const AudioCtor = audioGlobal.AudioContext ?? audioGlobal.webkitAudioContext;
    if (!AudioCtor) {
      return undefined;
    }
    AudioManager.context = new AudioCtor();
    return AudioManager.context;
  }
}

declare global {
  interface Window {
    webkitAudioContext?: typeof AudioContext;
  }
}
