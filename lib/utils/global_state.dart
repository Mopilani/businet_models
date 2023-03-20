class GlobalState {
  static GlobalState ins = GlobalState();

  static final Map<String, dynamic> _cache = {};

  static get(String key) => _cache[key];

  static  getdb() => _cache['db'];

  static set(String key, value) => _cache[key] = value;
}
