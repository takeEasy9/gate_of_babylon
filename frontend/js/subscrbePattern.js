class SubscribePattern {
  events = {};
  on(eventName, cb) {
    (this.events[eventName] ?? new Set()).add(cb);
  }
  off(eventName, cb) {
    this.events[eventName]?.delete(cb);
  }
  emit(eventName, ...args) {
    this.events[eventName]?.forEach((cb) => cb(...args));
  }
  once(eventName, cb) {
    const onceCb = () => {
      cb();
      this.off(eventName);
    };
    this.on(eventName, onceCb);
  }
}
