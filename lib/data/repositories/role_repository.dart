import 'package:fashion_app/data/sources/role_sources.dart';
import '../models/role_model.dart';
class RoleRepository {
  final FirebaseRoleSource _source;

  RoleRepository(this._source);

  Future<Role?> getRoleById(String roleId) async {
    try {
      return await _source.getRoleById(roleId);
    } catch (e) {
      print('Error fetching role: $e');
      return null;
    }
  }

  Future<List<Role>> getAllRoles() async {
    try {
      return await _source.getAllRoles();
    } catch (e) {
      print('Error fetching all roles: $e');
      return [];
    }
  }
}
