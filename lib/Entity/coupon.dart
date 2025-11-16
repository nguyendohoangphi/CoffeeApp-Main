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
    // Chuyển danh sách codes thành map với key ngẫu nhiên hoặc theo logic định sẵn
    return {for (var code in codes) code: code};
  }
}
