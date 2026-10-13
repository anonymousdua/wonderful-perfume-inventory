import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/perfume.dart';
import '../models/sale.dart';
import '../models/seller.dart';

/// All Supabase access lives here. ViewModels never touch the client directly.
class SupabaseService {
  SupabaseClient get _db => Supabase.instance.client;

  // ---- Perfumes ----
  Future<List<Perfume>> fetchPerfumes() async {
    final rows = await _db.from('perfumes').select().order('name');
    return rows.map<Perfume>((r) => Perfume.fromMap(r)).toList();
  }

  Future<void> insertPerfume({
    required String name,
    required String brand,
    required String category,
    required String size,
    required int units,
    required int reorderLevel,
    String? notes,
  }) async {
    await _db.from('perfumes').insert({
      'name': name,
      'brand': brand,
      'category': category,
      'size': size,
      'units': units,
      'reorder_level': reorderLevel,
      'notes': notes,
    });
  }

  Future<void> updatePerfume({
    required String id,
    required String name,
    required String brand,
    required String category,
    required String size,
    required int reorderLevel,
  }) async {
    await _db.from('perfumes').update({
      'name': name,
      'brand': brand,
      'category': category,
      'size': size,
      'reorder_level': reorderLevel,
    }).eq('id', id);
  }

  Future<void> addStock(String perfumeId, int quantity) async {
    await _db.rpc('add_stock', params: {
      'p_perfume_id': perfumeId,
      'p_quantity': quantity,
    });
  }

  // ---- Sellers ----
  Future<List<Seller>> fetchSellers() async {
    final rows =
        await _db.from('sellers').select().order('created_at', ascending: false);
    return rows.map<Seller>((r) => Seller.fromMap(r)).toList();
  }

  Future<void> insertSeller({required String name, String? email}) async {
    await _db.from('sellers').insert({'name': name, 'email': email});
  }

  // ---- Sales ----
  Future<List<Sale>> fetchSales() async {
    final rows = await _db
        .from('sales')
        .select('*, perfumes(name), sellers(name)')
        .order('created_at', ascending: false);
    return rows.map<Sale>((r) => Sale.fromMap(r)).toList();
  }

  Future<void> sellPerfume({
    required String perfumeId,
    required String sellerId,
    required int quantity,
    required String paymentMethod,
  }) async {
    await _db.rpc('sell_perfume', params: {
      'p_perfume_id': perfumeId,
      'p_seller_id': sellerId,
      'p_quantity': quantity,
      'p_payment_method': paymentMethod,
    });
  }
}
