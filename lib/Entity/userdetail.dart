class UserDetail {
  final String displayName;
  final String email;
  final String password;
  final String photoURL;
  late String rank;
  late int point;

  UserDetail({
    required this.displayName,
    required this.email,
    required this.password,
    required this.photoURL,
    required this.rank,
    required this.point,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    displayName: json['displayName'],
    email: json['email'],
    password: json['password'],
    photoURL: json['photoURL'],
    rank: json['rank'],
    point: json['point'],
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'email': email,
    'password': password,
    'photoURL': photoURL,
    'rank': rank,
    'point': point,
  };
}
