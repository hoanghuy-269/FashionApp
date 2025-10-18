class RolestaffModel {
  final String roleId;
  final String roleName;

  RolestaffModel({
    required this.roleId,
    required this.roleName,
  });

  factory RolestaffModel.fromMap(Map<String, dynamic> map) {
    return RolestaffModel(
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