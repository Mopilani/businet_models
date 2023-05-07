class UserLiteModel {
  UserLiteModel(this.id, this.firstname, this.lastname);
  late int id;
  String firstname = '';
  String lastname = '';

  Map<String, dynamic> toMap() => {
        'id': id,
        'fn': firstname,
        'ln': lastname,
      };

  static UserLiteModel fromMap(Map<String, dynamic> data) {
    return UserLiteModel(
      data['id'],
      data['fn'],
      data['ln'],
    );
  }
}