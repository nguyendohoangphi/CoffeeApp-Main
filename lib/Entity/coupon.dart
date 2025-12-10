class Coupon {
  final String email; // document ID
  final List<String> codes;

  Coupon({required this.email, required this.codes});

  factory Coupon.fromFirestore(String email, Map<String, dynamic> data) {
    return Coupon(
      email: email,
      codes: data.values.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {for (var code in codes) code: code};
  }
}
