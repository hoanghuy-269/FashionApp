import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:fashion_app/data/repositories/storestaffs_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  bool _isLoading = false;

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
      final isAddNew = model.employeeId.isEmpty;

      // CHỈ kiểm tra email exists khi THÊM MỚI
      if (isAddNew) {
        final emailExists = await isStaffEmailExists(model.email, model.shopId);
        if (emailExists) {
          throw Exception(
            'Email này đã được sử dụng, vui lòng chọn email khác.',
          );
        }
      }

      // Upload ảnh CCCD nếu có
      String? frontUrl = model.nationalIdFront;
      String? backUrl = model.nationalIdBack;

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

      // Tạo tài khoản CHỈ khi THÊM MỚI
      String docId = model.employeeId;

      if (isAddNew) {
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: model.email,
            password: password,
          );
          docId = userCredential.user?.uid ?? '';
        } on FirebaseAuthException catch (e) {
          if (e.code == "email-already-in-use") {
            throw Exception(
              'Email này đã được sử dụng, vui lòng chọn email khác.',
            );
          } else {
            throw Exception('Lỗi tạo tài khoản: ${e.message}');
          }
        }
      }

      // Cập nhật model
      final updated = model.copyWith(
        employeeId: docId,
        nationalIdFront: frontUrl,
        nationalIdBack: backUrl,
        createdAt: model.createdAt,
      );

      // Lưu vào Firestore
      await _firestore
          .collection('shops')
          .doc(updated.shopId)
          .collection('staff')
          .doc(docId)
          .set(updated.toFirestoreMap());

      // Cập nhật list cục bộ
      final index = staffs.indexWhere(
        (s) => s.employeeId == updated.employeeId,
      );
      if (index != -1) {
        staffs[index] = updated;
      } else {
        staffs.add(updated);
      }

      filteredStaffs = List.from(staffs);

      return updated;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StorestaffModel> updateStaff(
    StorestaffModel model, {
    File? front,
    File? back,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (model.employeeId.isEmpty) {
        throw Exception('Employee ID không được để trống khi cập nhật.');
      }

      // Upload ảnh CCCD nếu có ảnh mới
      String? frontUrl = model.nationalIdFront;
      String? backUrl = model.nationalIdBack;

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

      // Cập nhật model với dữ liệu mới
      final updated = model.copyWith(
        nationalIdFront: frontUrl,
        nationalIdBack: backUrl,
      );

      // Cập nhật vào Firestore
      await _firestore
          .collection('shops')
          .doc(updated.shopId)
          .collection('staff')
          .doc(updated.employeeId)
          .update(updated.toFirestoreMap());

      // Cập nhật list cục bộ
      final index = staffs.indexWhere(
        (s) => s.employeeId == updated.employeeId,
      );
      if (index != -1) {
        staffs[index] = updated;
        filteredStaffs = List.from(staffs);
      }

      return updated;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isStaffEmailExists(String email, String shopId) async {
    return await _repo.isStaffEmailExists(email, shopId);
  }

  // Trong StorestaffViewmodel

 Future<void> loadCurrentStaffFromAuth() async {
  try {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print("Không có user đang đăng nhập");
      _isLoading = false;
      notifyListeners();
      return;
    }

    print("User ID: ${user.uid}");

    // ← PHẢI TÌM STAFF TRONG TẤT CẢ CÁC SHOP
    final shopsSnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .get();

    StorestaffModel? foundStaff;

    // Duyệt qua từng shop để tìm staff
    for (var shopDoc in shopsSnapshot.docs) {
      final staffDoc = await shopDoc.reference
          .collection('staff')
          .where('employeeId', isEqualTo: user.uid)
          .get();

      if (staffDoc.docs.isNotEmpty) {
        foundStaff = StorestaffModel.fromMap(staffDoc.docs.first.data());
        print("Tìm thấy staff: ${foundStaff.fullName}, Shop: ${foundStaff.shopId}");
        break;
      }
    }

    if (foundStaff != null) {
      currentStaff = foundStaff; // ← Dùng currentStaff, không phải _currentStaff
      print("Loaded staff: ${currentStaff?.fullName}, Shop: ${currentStaff?.shopId}");
    } else {
      print("Không tìm thấy staff với uid: ${user.uid}");
    } 

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    print("Error loading staff: $e");
    _isLoading = false;
    notifyListeners();
  }
}
}
