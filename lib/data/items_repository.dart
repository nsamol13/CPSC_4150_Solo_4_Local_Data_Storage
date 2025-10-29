import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'db.dart';
import 'item.dart';

class ItemsRepository {
  static const _webItemsKey = 'items_json_v1';
  final AppDatabase _db = AppDatabase();

  Future<List<Item>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webItemsKey);
      if (raw == null || raw.isEmpty) return [];
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((m) => Item.fromMap(m))
            .toList();
        return list;
      } catch (_) {
        await prefs.remove(_webItemsKey);
        return [];
      }
    } else {
      try {
        final db = await _db.database;
        final rows = await db.query('items', orderBy: 'created_at DESC');
        return rows.map((m) => Item.fromMap(m)).toList();
      } catch (_) {
        try { await _db.reset(); } catch (_) {}
        return [];
      }
    }
  }

  Future<Item> insert(String text) async {
    final item = Item(text: text, createdAt: DateTime.now().millisecondsSinceEpoch);
    if (kIsWeb) {
      final items = await getAll();
      final nextId = (items.map((e) => e.id ?? 0).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
      final newItem = item.copyWith(id: nextId);
      await _saveWeb([...items..insert(0, newItem)]);
      return newItem;
    } else {
      final db = await _db.database;
      final id = await db.insert('items', item.toMap()..remove('id'));
      return item.copyWith(id: id);
    }
  }

  Future<void> update(Item item) async {
    if (kIsWeb) {
      final items = await getAll();
      final i = items.indexWhere((e) => e.id == item.id);
      if (i != -1) {
        items[i] = item;
        await _saveWeb(items);
      }
    } else {
      final db = await _db.database;
      await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    }
  }

  Future<void> delete(int id) async {
    if (kIsWeb) {
      final items = await getAll();
      items.removeWhere((e) => e.id == id);
      await _saveWeb(items);
    } else {
      final db = await _db.database;
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webItemsKey);
    } else {
      final db = await _db.database;
      await db.delete('items');
    }
  }

  Future<void> _saveWeb(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_webItemsKey, jsonList);
  }
}

