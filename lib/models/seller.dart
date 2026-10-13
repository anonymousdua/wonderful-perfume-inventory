class Seller {
  final String id;
  final String name;
  final String? email;

  const Seller({required this.id, required this.name, this.email});

  factory Seller.fromMap(Map<String, dynamic> m) => Seller(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String?,
      );
}
