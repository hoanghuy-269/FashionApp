import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:fashion_app/data/repositories/storestaffs_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StorestaffViewmodel extends ChangeNotifier {
  final StorestaffsRepositories _repo = StorestaffsRepositories();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late UserCredential userCredential;

  List<StorestaffModel> staffs = [];
  List<StorestaffModel> filteredStaffs = [];
  StorestaffModel? currentStaff;
  bool isLoading = false;
  bool isFetching = false;
  String? _lastFetchedShopId;

  Future<void> addNewStaff(StorestaffModel staff) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.addStaff(staff);
      staffs.add(staff);
      filteredStaffs = List.from(staffs);
    } catch (e) {
      debugPrint('Lỗi thêm nhân viên: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStaff(StorestaffModel staff) async {
    await _repo.updateStaff(staff);

    final update = staffs.indexWhere((s) => s.employeeId == staff.employeeId);
    if (update >= 0) {
      staffs[update] = staff;
      filteredStaffs = List.from(staffs);
    }
    notifyListeners();
  }

  Future<void> fetchStaffs(StorestaffModel staff) async {
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

  Future<void> fetchStaffsByShop(shopId) async {
    if (shopId == null || shopId.toString().isEmpty) {
      return;
    }
    if (_lastFetchedShopId == shopId && isFetching) {
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      staffs = await _repo.getStaffsByShop(shopId);
      filteredStaffs = List.from(staffs);
      _lastFetchedShopId = shopId;
    } catch (_) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchStaff(String query) {
    if (staffs.isEmpty) {
      return;
    }

    if (query.isEmpty) {
      filteredStaffs = List.from(staffs);
    } else {
      filteredStaffs =
          staffs
              .where(
                (staff) =>
                    staff.fullName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    notifyListeners();
  }

  Future<void> deleteStaff(String shopId, String employeeId) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.deleteStaff(shopId, employeeId);
      staffs.removeWhere((staff) => staff.employeeId == employeeId);
      filteredStaffs.removeWhere((staff) => staff.employeeId == employeeId);
    } catch (e) {
      debugPrint('Lỗi xóa nhân viên: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StorestaffModel> saveStaffWithAuth(
    StorestaffModel model, {
    required String password,
    File? front,
    File? back,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      String? frontUrl = model.nationalIdFront;
      String? backUrl = model.nationalIdBack;

      // Upload ảnh CCCD nếu có
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

      final isAddNew = model.employeeId.isEmpty;

      String docId = model.employeeId;
      if (isAddNew) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: model.email,
          password: password,
        );
        docId = userCredential.user?.uid ?? '';
      } else {
        docId = model.employeeId;
      }

      final updated = model.copyWith(
        employeeId: docId,
        nationalIdFront: frontUrl,
        nationalIdBack: backUrl,
        createdAt: model.createdAt,
      );

      if (updated.shopId.isEmpty) {
        throw Exception('shopId trống. Vui lòng cung cấp shopId hợp lệ trước khi lưu nhân viên.');
      }

      await _firestore
          .collection('shops')
          .doc(updated.shopId)
          .collection('staff')
          .doc(docId)
          .set(updated.toFirestoreMap());

      // B5. Cập nhật list cục bộ
      final exists = staffs.any((s) => s.employeeId == updated.employeeId);
      if (exists) {
        final index = staffs.indexWhere(
          (s) => s.employeeId == updated.employeeId,
        );
        staffs[index] = updated;
      } else {
        staffs.add(updated);
      }

      filteredStaffs = List.from(staffs);

      return updated;
    } on FirebaseAuthException catch (e) {
      // Provide a clearer message for common auth errors
      if (e.code == 'email-already-in-use' || e.code == 'email-already-in-use') {
        throw Exception('Email này đã được sử dụng bởi tài khoản khác.');
      }
      throw Exception(e.message ?? 'Lỗi xác thực: ${e.code}');
    } on PlatformException catch (e) {
      // On some platforms the plugin throws PlatformException
      if (e.code.toLowerCase().contains('email') || e.message?.toLowerCase().contains('email') == true) {
        throw Exception('Email này đã được sử dụng bởi tài khoản khác.');
      }
      throw Exception(e.message ?? e.code);
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
