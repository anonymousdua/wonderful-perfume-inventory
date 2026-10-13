import 'package:flutter/foundation.dart';

import '../models/seller.dart';
import '../services/supabase_service.dart';

class SellerViewModel extends ChangeNotifier {
  SellerViewModel(this._service);
  final SupabaseService _service;

  List<Seller> sellers = [];
  bool loading = false;
  bool saving = false;
  String? error;

  List<Seller> get recent => sellers.take(8).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      sellers = await _service.fetchSellers();
    } catch (e) {
      error = 'Could not load sellers: $e';
    }
    loading = false;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> save({required String name, String email = ''}) async {
    final n = name.trim();
    final e = email.trim();
    if (n.isEmpty) return 'Seller name is required.';
    if (e.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      return 'Enter a valid email address or leave it blank.';
    }
    saving = true;
    notifyListeners();
    try {
      await _service.insertSeller(name: n, email: e.isEmpty ? null : e);
      saving = false;
      await load();
      return null;
    } catch (err) {
      saving = false;
      notifyListeners();
      return 'Could not save seller: $err';
    }
  }
}
