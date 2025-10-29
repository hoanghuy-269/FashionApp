import 'package:fashion_app/data/models/role_model.dart';
import 'package:fashion_app/data/sources/role_remote_sources.dart';

class RoleRepository {
  final RoleRemoteSources _remoteSource = RoleRemoteSources();

  Future<List<RoleModel>> fetchRoles() async {
    return await _remoteSource.fetchRoles();
  }

  Future<RoleModel?> getRoleById(String id) async {
    return await _remoteSource.getRoleById(id);
  }
}
