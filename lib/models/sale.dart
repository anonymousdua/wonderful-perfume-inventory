class Sale {
  final String id;
  final int saleNo;
  final DateTime date;
  final String perfumeName;
  final String sellerName;
  final int quantity;
  final String paymentMethod;
  final String status;

  const Sale({
    required this.id,
    required this.saleNo,
    required this.date,
    required this.perfumeName,
    required this.sellerName,
    required this.quantity,
    required this.paymentMethod,
    required this.status,
  });

  /// Expects a row from: sales.select('*, perfumes(name), sellers(name)')
  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as String,
        saleNo: (m['sale_no'] as num).toInt(),
        date: DateTime.parse(m['created_at'] as String).toLocal(),
        perfumeName: (m['perfumes']?['name'] as String?) ?? 'Unknown',
        sellerName: (m['sellers']?['name'] as String?) ?? 'Unknown',
        quantity: (m['quantity'] as num).toInt(),
        paymentMethod: m['payment_method'] as String,
        status: m['status'] as String,
      );

  String get label => 'WP-$saleNo';

  String get dateLabel {
    final d = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$d/$mo/${date.year}';
  }
}
