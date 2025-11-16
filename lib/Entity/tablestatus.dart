class TableStatus {
  final String id;
  final String createDate;
  final String nameTable;
  late bool isBooked;

  TableStatus({
    required this.id,
    required this.createDate,
    required this.nameTable,
    required this.isBooked,
  });

  factory TableStatus.fromJson(Map<String, dynamic> json) => TableStatus(
    id: json['id'],
    createDate: json['createDate'],
    nameTable: json['nameTable'],
    isBooked: json['isBooked'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createDate': createDate,
    'nameTable': nameTable,
    'isBooked': isBooked,
  };
}
