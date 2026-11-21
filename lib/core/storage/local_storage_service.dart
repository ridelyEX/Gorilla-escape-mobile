import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyPlayerProfile = 'player_profile_v1';
  static const String _keyMatchHistory = 'match_history_v1';
  static const String _keyPendingSyncQueue = 'pending_sync_queue_v1';
  static const String _keyApiBaseUrl = 'api_base_url_v1';
  static const String _keyForceMockMode = 'force_mock_mode_v1';
  static const String _keyDojoBestSwing = 'dojo_best_swing_v1';
  static const String _keyDojoBestBalance = 'dojo_best_balance_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  String get apiBaseUrl =>
      _prefs.getString(_keyApiBaseUrl) ?? 'http://192.168.1.100:8080';

  Future<void> setApiBaseUrl(String url) async {
    await _prefs.setString(_keyApiBaseUrl, url.trim());
  }

  bool get forceMockMode => _prefs.getBool(_keyForceMockMode) ?? true;

  Future<void> setForceMockMode(bool value) async {
    await _prefs.setBool(_keyForceMockMode, value);
  }

  Map<String, dynamic>? getPlayerProfileJson() {
    final raw = _prefs.getString(_keyPlayerProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlayerProfileJson(Map<String, dynamic> json) async {
    await _prefs.setString(_keyPlayerProfile, jsonEncode(json));
  }

  Map<String, dynamic>? getCachedDashboardJson() {
    final raw = _prefs.getString(_keyMatchHistory);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedDashboardJson(Map<String, dynamic> json) async {
    await _prefs.setString(_keyMatchHistory, jsonEncode(json));
  }

  List<Map<String, dynamic>> getPendingSyncQueue() {
    final raw = _prefs.getString(_keyPendingSyncQueue);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueueSyncPayload(Map<String, dynamic> payload) async {
    final current = getPendingSyncQueue();
    current.add({
      ...payload,
      'queuedAt': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_keyPendingSyncQueue, jsonEncode(current));
  }

  Future<void> clearPendingSyncQueue() async {
    await _prefs.remove(_keyPendingSyncQueue);
  }

  double get dojoBestSwing => _prefs.getDouble(_keyDojoBestSwing) ?? 0.0;

  Future<void> setDojoBestSwing(double power) async {
    if (power > dojoBestSwing) {
      await _prefs.setDouble(_keyDojoBestSwing, power);
    }
  }

  double get dojoBestBalanceTime =>
      _prefs.getDouble(_keyDojoBestBalance) ?? 0.0;

  Future<void> setDojoBestBalanceTime(double seconds) async {
    final current = dojoBestBalanceTime;
    if (current == 0.0 || seconds < current) {
      await _prefs.setDouble(_keyDojoBestBalance, seconds);
    }
  }
}
