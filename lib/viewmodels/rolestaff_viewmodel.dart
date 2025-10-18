import 'package:fashion_app/data/models/rolestaff_model.dart';
import 'package:fashion_app/data/repositories/rolestaff_repositories.dart';
import 'package:flutter/material.dart';

class RolestaffViewmodel  extends ChangeNotifier{
  final RolestaffRepositories _repositories = RolestaffRepositories();
  List<RolestaffModel> _roles = [];

  bool _isLoading = false;

  List<RolestaffModel> get roles => _roles;
  bool get isLoading => _isLoading;

  Future<void> fetchRoles() async{
    _isLoading = true;
    notifyListeners();
    try {
      _roles = await _repositories.getRoles();
    } catch (e) {
      print("Lỗi khi lấy vai trò nhân viên: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}