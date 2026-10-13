enum StockStatus { inStock, lowStock, outOfStock }

class Perfume {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String size;
  final int units;
  final int reorderLevel;
  final String? notes;

  const Perfume({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.size,
    required this.units,
    required this.reorderLevel,
    this.notes,
  });

  factory Perfume.fromMap(Map<String, dynamic> m) => Perfume(
        id: m['id'] as String,
        name: m['name'] as String,
        brand: m['brand'] as String,
        category: m['category'] as String,
        size: m['size'] as String,
        units: (m['units'] as num).toInt(),
        reorderLevel: (m['reorder_level'] as num).toInt(),
        notes: m['notes'] as String?,
      );

  StockStatus get status {
    if (units <= 0) return StockStatus.outOfStock;
    if (units <= reorderLevel) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}
