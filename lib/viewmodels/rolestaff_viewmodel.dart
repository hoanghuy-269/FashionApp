import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/rolestaff_model.dart';
import 'package:fashion_app/data/repositories/rolestaff_repositories.dart';

class RolestaffViewmodel extends ChangeNotifier {
  final RolestaffRepositories _repositories = RolestaffRepositories();
  List<RolestaffModel> _roles = [];
  bool _isLoading = false;

  List<RolestaffModel> get roles => _roles;
  bool get isLoading => _isLoading;

  Future<void> fetchRoles({bool force = false}) async {
    if(_roles.isNotEmpty && !force) return;
    _isLoading = true;
    notifyListeners();
    try {
      _roles = await _repositories.getRoles();
    } catch (e) {
      debugPrint("Lỗi khi lấy vai trò nhân viên: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy tên vai trò từ roleId 
  String getRoleName(String roleId, {String fallback = '-'}) {
    if (_roles.isEmpty) return fallback;
    final role = _roles.firstWhere(
      (r) => r.roleId == roleId,
      orElse: () => RolestaffModel(roleId: roleId, roleName: fallback),
    );
    return role.roleName;
  }
}
