class RoleModel {
  final String id;
  final String name; // user -- Shop

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(id: map['id'] as String, name: map['name'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
