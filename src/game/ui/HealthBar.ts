export interface HealthBarSnapshot {
  current: number;
  max: number;
}

export function healthPercent(snapshot: HealthBarSnapshot): number {
  if (snapshot.max <= 0) {
    return 0;
  }
  return Math.max(0, Math.min(100, Math.round((snapshot.current / snapshot.max) * 100)));
}
