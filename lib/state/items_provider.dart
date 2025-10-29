import 'package:flutter/foundation.dart';
import '../data/item.dart';
import '../data/items_repository.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemsRepository _repo = ItemsRepository();

  List<Item> _items = [];
  bool _loading = false;
  String? _error;

  List<Item> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    await load();
  }

  Future<void> load() async {
    _setLoading(true);
    try {
      _items = await _repo.getAll();
      _error = null;
    } catch (e) {
      _error = 'Failed to load: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> add(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final item = await _repo.insert(trimmed);
    _items = [item, ..._items];
    notifyListeners();
    return true;
  }

  Future<void> edit(Item item, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;
    final updated = item.copyWith(text: trimmed);
    await _repo.update(updated);
    final i = _items.indexWhere((it) => it.id == item.id);
    if (i != -1) {
      _items[i] = updated;
      notifyListeners();
    }
  }

  Future<void> remove(Item item) async {
    if (item.id == null) return;
    await _repo.delete(item.id!);
    _items.removeWhere((it) => it.id == item.id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    _items = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
