import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server.dart';

class ServerStorage extends ChangeNotifier {
  static const String _serversKey = 'saved_servers';
  static const String _activeIndexKey = 'active_server_index';

  List<ServerInfo> _servers = [];
  int _activeIndex = -1;

  List<ServerInfo> get servers => List.unmodifiable(_servers);
  int get activeIndex => _activeIndex;

  ServerInfo? getActiveServer() {
    if (_activeIndex >= 0 && _activeIndex < _servers.length) {
      return _servers[_activeIndex];
    }
    return null;
  }

  Future<void> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_serversKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _servers = jsonList
            .map((item) => ServerInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Failed to load servers: $e');
        _servers = [];
      }
    }
    _activeIndex = prefs.getInt(_activeIndexKey) ?? -1;
    // Clamp active index to valid range
    if (_activeIndex >= _servers.length) {
      _activeIndex = _servers.isEmpty ? -1 : 0;
    }
    notifyListeners();
  }

  Future<void> saveServers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_servers.map((s) => s.toJson()).toList());
    await prefs.setString(_serversKey, jsonString);
    await prefs.setInt(_activeIndexKey, _activeIndex);
  }

  Future<void> addServer(ServerInfo server) async {
    _servers.add(server);
    // Auto-select first server added
    if (_servers.length == 1) {
      _activeIndex = 0;
    }
    await saveServers();
    notifyListeners();
  }

  Future<void> addServers(List<ServerInfo> servers) async {
    final wasEmpty = _servers.isEmpty;
    _servers.addAll(servers);
    if (wasEmpty && _servers.isNotEmpty) {
      _activeIndex = 0;
    }
    await saveServers();
    notifyListeners();
  }

  Future<void> removeServer(int index) async {
    if (index < 0 || index >= _servers.length) return;
    _servers.removeAt(index);
    // Adjust active index after removal
    if (_servers.isEmpty) {
      _activeIndex = -1;
    } else if (index == _activeIndex) {
      _activeIndex = 0;
    } else if (index < _activeIndex) {
      _activeIndex--;
    }
    await saveServers();
    notifyListeners();
  }

  Future<void> setActiveIndex(int index) async {
    if (index >= 0 && index < _servers.length) {
      _activeIndex = index;
      await saveServers();
      notifyListeners();
    }
  }

  Future<void> updateServer(int index, ServerInfo server) async {
    if (index < 0 || index >= _servers.length) return;
    _servers[index] = server;
    await saveServers();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _servers.clear();
    _activeIndex = -1;
    await saveServers();
    notifyListeners();
  }
}
