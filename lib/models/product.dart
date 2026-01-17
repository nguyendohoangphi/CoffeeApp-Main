//trans data enum(kiểu liệt kê) thành data Firestore string
String enumToString(Object enumValue) => enumValue.toString().split('.').last;

//trans data from Fristore string thành object enum
T stringToEnum<T>(List<T> values, String value) => values.firstWhere(
  (e) => enumToString(e!) == value,
  orElse: () => values.first,
);

class Product {
  //final no change after create
  final String createDate;
  final String name;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  late double price;
  final String type;

//contrustor
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

//factory contrustor -> no need make new instance and it can return instance có sẵn
//Map<.....> json -> deserialization(giải mã) : trabs data from Firebase thành Object class
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

//Map<...> toJson() => serialization(mã hoá): đóng gói obeject class , gủi data lên Firestore
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
