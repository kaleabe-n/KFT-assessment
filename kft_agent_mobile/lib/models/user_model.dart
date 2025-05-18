class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final double balance;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['email'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      balance: json['balance'] ?? 0.0,
    );
  }
}
