import 'package:flutter/foundation.dart';

import '../models/perfume.dart';
import '../services/supabase_service.dart';

enum InventorySort { name, units }

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._service);
  final SupabaseService _service;

  List<Perfume> _perfumes = [];
  bool loading = false;
  String? error;

  String search = '';
  String category = 'All categories';
  String stockFilter = 'All stock levels';
  InventorySort sortBy = InventorySort.name;
  bool ascending = true;

  static const categories = [
    'Eau de Parfum',
    'Eau de Toilette',
    'Parfum',
    'Eau de Cologne',
  ];
  static const stockLevels = ['In Stock', 'Low Stock', 'Out of Stock'];

  int get perfumeTypes => _perfumes.length;
  int get totalUnits => _perfumes.fold(0, (s, p) => s + p.units);
  int get needAttention =>
      _perfumes.where((p) => p.status != StockStatus.inStock).length;

  List<Perfume> get visible {
    final q = search.trim().toLowerCase();
    final list = _perfumes.where((p) {
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
      final matchesCategory =
          category == 'All categories' || p.category == category;
      final matchesStock = stockFilter == 'All stock levels' ||
          statusLabel(p.status) == stockFilter;
      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    list.sort((a, b) {
      final r = sortBy == InventorySort.name
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : a.units.compareTo(b.units);
      return ascending ? r : -r;
    });
    return list;
  }

  static String statusLabel(StockStatus s) {
    switch (s) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _perfumes = await _service.fetchPerfumes();
    } catch (e) {
      error = 'Could not load inventory: $e';
    }
    loading = false;
    notifyListeners();
  }

  void setSearch(String v) {
    search = v;
    notifyListeners();
  }

  void setCategory(String v) {
    category = v;
    notifyListeners();
  }

  void setStockFilter(String v) {
    stockFilter = v;
    notifyListeners();
  }

  void toggleSort(InventorySort column) {
    if (sortBy == column) {
      ascending = !ascending;
    } else {
      sortBy = column;
      ascending = true;
    }
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> addStock(Perfume p, int quantity) async {
    if (quantity <= 0) return 'Enter a quantity greater than 0.';
    try {
      await _service.addStock(p.id, quantity);
      await load();
      return null;
    } catch (e) {
      return 'Could not add stock: $e';
    }
  }

  Future<String?> updatePerfume({
    required Perfume perfume,
    required String name,
    required String brand,
    required String category,
    required String size,
    required int reorderLevel,
  }) async {
    if (name.trim().isEmpty || brand.trim().isEmpty || size.trim().isEmpty) {
      return 'Name, brand and size are required.';
    }
    try {
      await _service.updatePerfume(
        id: perfume.id,
        name: name.trim(),
        brand: brand.trim(),
        category: category,
        size: size.trim(),
        reorderLevel: reorderLevel,
      );
      await load();
      return null;
    } catch (e) {
      return 'Could not save changes: $e';
    }
  }
}
