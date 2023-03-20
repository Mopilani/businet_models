import 'dart:convert';

class DeliveryDriverModel {
  dynamic id;
  late String name;
  late String phoneNumber;
  String? address;
  late bool inactive;

  static DeliveryDriverModel fromMap(Map<String, dynamic> data) {
    DeliveryDriverModel model = DeliveryDriverModel();
    model.id = data['id'];
    model.name = data['name'];
    model.phoneNumber = data['phoneNumber'];
    model.address = data['address'];
    model.inactive = data['inactive'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'inactive': inactive,
      };

  String toJson() => json.encode(toMap());

  static DeliveryDriverModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }
}
