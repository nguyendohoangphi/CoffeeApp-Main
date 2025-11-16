class ProductFavourite {
  final String email;
  final String productName;

  ProductFavourite({required this.email, required this.productName});

  factory ProductFavourite.fromJson(Map<String, dynamic> json) =>
      ProductFavourite(email: json['email'], productName: json['productName']);

  Map<String, dynamic> toJson() => {'email': email, 'productName': productName};
}
