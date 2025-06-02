class Teacher {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String phone;
  final String email;
  final DateTime createdAt;

  Teacher({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      phone: map['phone'],
      email: map['email'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Teacher copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? phone,
    String? email,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
