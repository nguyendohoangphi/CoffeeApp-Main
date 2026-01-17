class UserDetail {
  final String uid;
  final String username;
  final String email;
  String? password;
  final String photoURL;
  String rank;
  int point;
  String role;
  String? phone; 



  UserDetail({
    required this.uid,
    required this.username,
    required this.email,
    this.password,
    required this.photoURL,
    required this.rank,
    required this.point,
    required this.role,
    this.phone,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    uid: json['uid'] ?? "",
    username: json['username'] ?? "Unknown User",
    email: json['email'] ?? "",
    password: json['password'] ?? "",
    photoURL: json['photoURL'] ?? "",
    rank: json['rank'] ?? "Bronze",
    point: json['point'] ?? 0,
    role: json['role'] ?? "user",
    phone: json['phone'],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "username": username,
    "email": email,
    "password": password,
    "photoURL": photoURL,
    "rank": rank,
    "point": point,
    "role": role,
    "phone": phone, 
  };
}
