class User {
  final String login;
  final String username;
  final String email;
  final bool active;
  final String activationCode;
  final bool privAdmin;
  final String mfa;
  final String picture;
  final String role;
  final String phone;

  User({
    required this.login,
    required this.username,
    required this.email,
    required this.active,
    required this.activationCode,
    required this.privAdmin,
    required this.mfa,
    required this.picture,
    required this.role,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      username: json['username'],
      email: json['email'],
      active: json['active'] == '1',
      activationCode: json['activation_code'],
      privAdmin: json['priv_admin'] == '1',
      mfa: json['mfa'],
      picture: json['picture'],
      role: json['role'],
      phone: json['phone'],
    );
  }
}
