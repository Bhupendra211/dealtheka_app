class UserModel {
  final String id;
  final String name;
  final String email;
  final String number;
  final String? profile;

  UserModel({required this.id, required this.name, required this.email, required this.number, this.profile});

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      number: json['number']??'',
      profile: json['img'], // optional, no need for default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'number': number,
    };
  }

}
