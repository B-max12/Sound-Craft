import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

/// Settings stored in the DB (key→JSON) with schema versioning (§6.1
/// UserPreferences). Simple typed accessors keep call sites clean.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.jsonValue;
  }

  Future<void> _set(String key, Object? value) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            jsonValue: jsonEncode(value),
            modifiedAt: DateTime.now(),
          ),
        );
  }

  Future<String?> getString(String key) async {
    final raw = await _get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as String?;
  }

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final raw = await _get(key);
    if (raw == null) return fallback;
    return jsonDecode(raw) as bool? ?? fallback;
  }

  Future<void> setString(String key, String value) => _set(key, value);
  Future<void> setBool(String key, bool value) => _set(key, value);
  Future<void> setStringList(String key, List<String> value) =>
      _set(key, value);

  Future<List<String>> getStringList(String key) async {
    final raw = await _get(key);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    return (decoded as List).cast<String>();
  }

  /// Factory reset of settings rows (Settings "Reset" action). Does not touch
  /// library, playlists or files.
  Future<void> resetAll() async {
    await _db.delete(_db.settings).go();
  }
}

/// Provider discovery cache (§6.2 provider_cache_metadata) with per-key TTL.
class ProviderCacheRepository {
  ProviderCacheRepository(this._db);

  final AppDatabase _db;

  Future<String?> getJson(String key) async {
    final row = await (_db.select(
      _db.providerCache,
    )..where((c) => c.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    final expires = row.fetchedAt.add(Duration(seconds: row.ttlSeconds));
    if (DateTime.now().isAfter(expires)) return null;
    return row.json;
  }

  Future<void> putJson(String key, String json, {int ttlSeconds = 300}) async {
    await _db
        .into(_db.providerCache)
        .insertOnConflictUpdate(
          ProviderCacheCompanion.insert(
            key: key,
            json: json,
            fetchedAt: DateTime.now(),
            ttlSeconds: Value(ttlSeconds),
          ),
        );
  }

  /// Clears ONLY expendable provider metadata cache (SET-003 scope discipline:
  /// never downloaded files, never imported audio).
  Future<int> clear() async {
    return _db.delete(_db.providerCache).go();
  }
}
