import 'package:flutter/foundation.dart';

import '../models/perfume.dart';
import '../models/sale.dart';
import '../models/seller.dart';
import '../services/supabase_service.dart';

enum DateRangeFilter { all, today, week }

class SalesViewModel extends ChangeNotifier {
  SalesViewModel(this._service);
  final SupabaseService _service;

  List<Sale> _sales = [];
  List<Perfume> perfumes = [];
  List<Seller> sellers = [];
  bool loading = false;
  String? error;

  String search = '';
  DateRangeFilter range = DateRangeFilter.all;
  String statusFilter = 'All statuses';

  static const paymentMethods = ['Card', 'Cash', 'Bank transfer'];
  static const statuses = ['Completed'];

  List<Perfume> get sellablePerfumes =>
      perfumes.where((p) => p.units > 0).toList();

  List<Sale> get visible {
    final q = search.trim().toLowerCase();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _sales.where((s) {
      final matchesSearch = q.isEmpty ||
          s.label.toLowerCase().contains(q) ||
          s.perfumeName.toLowerCase().contains(q) ||
          s.sellerName.toLowerCase().contains(q);
      final matchesRange = switch (range) {
        DateRangeFilter.all => true,
        DateRangeFilter.today => !s.date.isBefore(startOfToday),
        DateRangeFilter.week =>
          !s.date.isBefore(startOfToday.subtract(const Duration(days: 6))),
      };
      final matchesStatus =
          statusFilter == 'All statuses' || s.status == statusFilter;
      return matchesSearch && matchesRange && matchesStatus;
    }).toList();
  }

  int get unitsSold => _sales
      .where((s) => s.status == 'Completed')
      .fold(0, (sum, s) => sum + s.quantity);

  int get completedOrders => _sales.where((s) => s.status == 'Completed').length;

  int get todaysOrders {
    final now = DateTime.now();
    return _sales
        .where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
        .length;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _sales = await _service.fetchSales();
      perfumes = await _service.fetchPerfumes();
      sellers = await _service.fetchSellers();
    } catch (e) {
      error = 'Could not load sales: $e';
    }
    loading = false;
    notifyListeners();
  }

  void setSearch(String v) {
    search = v;
    notifyListeners();
  }

  void setRange(DateRangeFilter v) {
    range = v;
    notifyListeners();
  }

  void setStatus(String v) {
    statusFilter = v;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> sell({
    required Perfume? perfume,
    required Seller? seller,
    required int quantity,
    required String paymentMethod,
  }) async {
    if (perfume == null) return 'Choose a perfume.';
    if (seller == null) return 'Choose a seller (add one first if the list is empty).';
    if (quantity <= 0) return 'Enter a quantity greater than 0.';
    if (quantity > perfume.units) {
      return 'Only ${perfume.units} unit(s) of ${perfume.name} available.';
    }
    try {
      await _service.sellPerfume(
        perfumeId: perfume.id,
        sellerId: seller.id,
        quantity: quantity,
        paymentMethod: paymentMethod,
      );
      await load();
      return null;
    } catch (e) {
      return 'Could not complete sale: $e';
    }
  }
}
