import 'package:fashion_app/data/models/role_model.dart';
import 'package:fashion_app/data/sources/role_sources.dart';

class RoleRepository {
  final RoleRepository _remoteSource = RoleRepository();

  Future<List<RoleModel>> fetchRoles() async {
    return await _remoteSource.fetchRoles();
  }

  Future<RoleModel?> getRoleById(String id) async {
    return await _remoteSource.getRoleById(id);
  }
}
