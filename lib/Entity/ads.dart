class Ads {
  final String id;
  final String createDate;
  final String name;
  final String imageUrl;

  Ads({
    required this.id,
    required this.createDate,
    required this.name,
    required this.imageUrl,
  });

factory Ads.fromJson(Map<String, dynamic> json, String docId) {
  return Ads(
    id: docId,
    createDate: json['createDate'] ?? '',
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
  );
}


  Map<String, dynamic> toJson() => {
    'id': id,
    'createDate': createDate,
    'name': name,
    'imageUrl': imageUrl,
  };
}
