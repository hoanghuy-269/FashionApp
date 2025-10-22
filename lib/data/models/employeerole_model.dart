class EmployeeroleModel {
  final String roleId;
  final String roleName;

  EmployeeroleModel({
    required this.roleId,
    required this.roleName,
  });

  factory EmployeeroleModel.fromMap(Map<String, dynamic> map) {
    return EmployeeroleModel(
      roleId: map['roleId'],
      roleName: map['roleName'],
    );
  }  
  Map<String, dynamic> toMap() {
    return {
      'roleId': roleId,
      'roleName': roleName,
    };
  }
}