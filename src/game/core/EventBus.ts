type EventMap = Record<string, unknown>;

export class EventBus<TEvents extends EventMap> {
  private readonly listeners = new Map<keyof TEvents, Set<(payload: TEvents[keyof TEvents]) => void>>();

  on<TKey extends keyof TEvents>(eventName: TKey, listener: (payload: TEvents[TKey]) => void): () => void {
    const listenersForEvent = this.listeners.get(eventName) ?? new Set();
    listenersForEvent.add(listener as (payload: TEvents[keyof TEvents]) => void);
    this.listeners.set(eventName, listenersForEvent);
    return () => listenersForEvent.delete(listener as (payload: TEvents[keyof TEvents]) => void);
  }

  emit<TKey extends keyof TEvents>(eventName: TKey, payload: TEvents[TKey]): void {
    this.listeners.get(eventName)?.forEach((listener) => listener(payload));
  }
}
