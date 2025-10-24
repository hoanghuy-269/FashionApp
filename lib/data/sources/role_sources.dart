import 'package:fashion_app/data/models/role_model.dart';

class RoleSources {
  // Danh sách role cố định
  final List<RoleModel> _roles = [
    RoleModel(id: 'R1', name: 'Shop'),
    RoleModel(id: 'R2', name: 'User'),
  ];

  // Giả lập load từ server / Firestore
  Future<List<RoleModel>> fetchRoles() async {
    await Future.delayed(const Duration(milliseconds: 300)); // giả delay
    return _roles;
  }

  Future<RoleModel?> getRoleById(String id) async {
    return _roles.firstWhere(
      (role) => role.id == id,
      orElse: () => RoleModel(id: '', name: ''),
    );
  }
}
