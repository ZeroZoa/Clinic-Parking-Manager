class DiscountType {
  final String id;
  final String discountName;
  final double discountValue;

  DiscountType({
    required this.id,
    required this.discountName,
    required this.discountValue,
  });

  factory DiscountType.fromJson(Map<String, dynamic> json) {
    return DiscountType(
      id: json['id'],
      discountName: json['discount_name'],
      discountValue: json['discount_value'].toDouble(),
    );
  }

  @override
  String toString() {
    return 'DiscountType(id: $id, discountName: $discountName, discountValue: $discountValue)';
  }
}
