import 'package:fashion_app/data/repositories/role_repository.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/role_model.dart';

class RoleViewModel extends ChangeNotifier {
  final RoleRepository _repo = RoleRepository();

  String? _selectedRoleId;
  String? get selectedRoleId => _selectedRoleId;

  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _roles = await _repo.fetchRoles();
    } catch (e) {
      debugPrint('Lỗi load roles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRole(String id) {
    _selectedRoleId = id;
    notifyListeners();
  }

  RoleModel? getRoleById(String id) {
    try {
      return _roles.firstWhere((role) => role.id == id);
    } catch (_) {
      return null;
    }
  }
}
