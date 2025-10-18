import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/data/repositories/staff_repositories.dart';
import 'package:flutter/material.dart';

class ShopStaffViewmodel extends ChangeNotifier {
  final StaffRepositories _repo = StaffRepositories();
  List<ShopstaffModel> staffs = [];
  ShopstaffModel? currentStaff;

  bool isLoading = false;

  Future<void> addNewStaff(ShopstaffModel staff) async{
    await _repo.addStaff(staff);
    staffs.add(staff);
    notifyListeners();
  }
  Future<void> fetchStaffs() async {
    isLoading = true;
    notifyListeners();

    staffs = await _repo.getStaffs();

    isLoading = false;
    notifyListeners();
  }
  Future<void> fetchStaffById(String employeeId) async {
    isLoading = true;
    notifyListeners();

    final staff = await _repo.getStaffById(employeeId);
    if (staff != null) {
      currentStaff = staff;
    } else {
      currentStaff = null;
    }

    isLoading = false;
    notifyListeners();
  }
}