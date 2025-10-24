import 'package:flutter/material.dart';
import '../data/models/role_model.dart';
import '../data/repositories/role_repositories.dart';
import '../data/sources/role_remote_sources.dart';

class RoleViewModel extends ChangeNotifier {
  final RoleRepository _repository = RoleRepository(FirebaseRoleSource());

  bool _isLoading = false;
  Role? _currentRole;
  List<Role> _roles = [];

  bool get isLoading => _isLoading;
  Role? get currentRole => _currentRole;
  List<Role> get roles => _roles;

  /// Lấy role theo ID
  Future<Role?> fetchRoleById(String? id) async {
    if (id == null) return null;
    final role = await _repository.getRoleById(id);
    _currentRole = role;
    notifyListeners();
    return role;
  }

  /// Lấy tất cả role
  Future<void> fetchAllRoles() async {
    _isLoading = true;
    notifyListeners();

    _roles = await _repository.getAllRoles();

    _isLoading = false;
    notifyListeners();
  }
}
