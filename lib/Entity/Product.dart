// ignore: duplicate_ignore
// ignore: file_names, constant_identifier_names
// ignore_for_file: file_names, constant_identifier_names

String enumToString(Object enumValue) => enumValue.toString().split('.').last;
T stringToEnum<T>(List<T> values, String value) =>
    values.firstWhere((e) => enumToString(e!) == value);

class Product {
  final String createDate;
  final String name;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  late double price;
  final String type;

  Product({
    required this.createDate,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    createDate: json['createDate'],
    name: json['name'],
    imageUrl: json['imageUrl'],
    description: json['description'],
    rating: (json['rating'] as num).toDouble(),
    reviewCount: json['reviewCount'],
    price: (json['price'] as num).toDouble(),
    type: json['type'],
  );

  Map<String, dynamic> toJson() => {
    'createDate': createDate,
    'name': name,
    'imageUrl': imageUrl,
    'description': description,
    'rating': rating,
    'reviewCount': reviewCount,
    'price': price,
    'type': enumToString(type),
  };
}
