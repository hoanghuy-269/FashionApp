import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/data/repositories/staff_repositories.dart';
import 'package:flutter/material.dart';

class ShopStaffViewmodel extends ChangeNotifier {
  final StaffRepositories _repo = StaffRepositories();
  List<ShopstaffModel> staffs = [];
  ShopstaffModel? currentStaff;

  bool isLoading = false;

  Future<void> addNewStaff(ShopstaffModel staff) async {
    await _repo.addStaff(staff);
    staffs.add(staff);
    notifyListeners();
  }

  Future<void> updateStaff(ShopstaffModel staff) async {
    await _repo.updateStaff(staff);

    final update = staffs.indexWhere((s) => s.employeeId == staff.employeeId);
    if (update >= 0) {
      staffs[update] = staff;
    }
    notifyListeners();
  }

  Future<void> fetchStaffs(ShopstaffModel staff) async {
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

  Future<void> fetchStaffsByShop(String shopId) async {
    isLoading = true;
    notifyListeners();

    try {
      staffs = await _repo.getStaffsByShop(shopId);
    } catch (e) {
      debugPrint('Error fetching staffs by shop: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> deleteStaff(String employeeId) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.deleteStaff(employeeId);
      staffs.removeWhere((staff) => staff.employeeId == employeeId);
    } catch (e) {
      debugPrint('Error deleting staff: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ShopstaffModel> saveStaff(
    ShopstaffModel model, {
    File? front,
    File? back,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      String? frontUrl = model.nationalIdFront;
      String? backUrl = model.nationalIdBack;

      // generate Firestore auto-id if employeeId not provided
      String employeeId = model.employeeId;
      if (employeeId.isEmpty) {
        employeeId = FirebaseFirestore.instance.collection('shopstaffs').doc().id;
      }

      if (front != null) {
        frontUrl = await GalleryUtil.uploadImageToFirebase(
          front,
          folderName: 'staff_ids/front',
        );
      }
      if (back != null) {
        backUrl = await GalleryUtil.uploadImageToFirebase(
          back,
          folderName: 'staff_ids/back',
        );
      }

      final updated = ShopstaffModel(
        employeeId: employeeId,
        shopId: model.shopId,
        fullName: model.fullName,
        password: model.password,
        nameaccount: model.nameaccount,
        nationalId: model.nationalId,
        nationalIdFront: frontUrl,
        nationalIdBack: backUrl,
        roleIds: model.roleIds,
        createdAt: model.createdAt,
      );

      final exists = staffs.any((s) => s.employeeId == updated.employeeId);
      if (exists) {
        await updateStaff(updated);
      } else {
        await addNewStaff(updated);
      }

      return updated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
