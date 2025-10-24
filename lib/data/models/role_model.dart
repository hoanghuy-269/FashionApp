class Role {
  final String id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromFirestore(Map<String, dynamic> json, String id) {
    return Role(id: id, name: json['name'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
