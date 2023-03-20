
class SystemCache {
  static final Map<String, dynamic> _cache = <String, dynamic>{};

  static SystemCache ins = SystemCache();

  static T? get<T>(String key) => _cache[key];

  static void set(String key, dynamic value) => _cache[key] = value;

  static void remove(String key) => _cache.remove(key);
}
