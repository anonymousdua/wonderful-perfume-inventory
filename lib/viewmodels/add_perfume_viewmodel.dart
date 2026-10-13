import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';

class AddPerfumeViewModel extends ChangeNotifier {
  AddPerfumeViewModel(this._service);
  final SupabaseService _service;

  bool saving = false;

  static const categories = [
    'Eau de Parfum',
    'Eau de Toilette',
    'Parfum',
    'Eau de Cologne',
  ];

  /// Returns an error message, or null on success.
  Future<String?> save({
    required String name,
    required String brand,
    required String? category,
    required String size,
    required String quantity,
    required String reorderLevel,
    required String notes,
  }) async {
    if (name.trim().isEmpty ||
        brand.trim().isEmpty ||
        size.trim().isEmpty ||
        category == null) {
      return 'Name, brand, category and bottle size are required.';
    }
    final qty = int.tryParse(quantity.trim());
    if (qty == null || qty < 0) return 'Initial quantity must be 0 or more.';
    final reorder = reorderLevel.trim().isEmpty ? 5 : int.tryParse(reorderLevel.trim());
    if (reorder == null || reorder < 0) return 'Reorder level must be 0 or more.';

    saving = true;
    notifyListeners();
    try {
      await _service.insertPerfume(
        name: name.trim(),
        brand: brand.trim(),
        category: category,
        size: size.trim(),
        units: qty,
        reorderLevel: reorder,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      );
      saving = false;
      notifyListeners();
      return null;
    } catch (e) {
      saving = false;
      notifyListeners();
      return 'Could not add perfume: $e';
    }
  }
}
