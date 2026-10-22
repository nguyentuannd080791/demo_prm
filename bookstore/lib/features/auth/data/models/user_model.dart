import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    super.userId,
    required super.username,
    super.email,
    super.role,
    super.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int? parseUserId(dynamic id) {
      if (id is int) return id;
      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id);
      return null;
    }

    return UserModel(
      userId: parseUserId(json['userId'] ?? json['id']),
      username: (json['username'] ?? '').toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (userId != null) 'userId': userId,
        'username': username,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (fullName != null) 'fullName': fullName,
      };
}
