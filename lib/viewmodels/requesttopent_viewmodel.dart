import 'package:flutter/foundation.dart';
// removed unused import
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:fashion_app/data/repositories/requesttoopent_repository.dart';

class RequestToOpenShopViewModel extends ChangeNotifier {
  final RequestToOpenShopRepository _repo = RequestToOpenShopRepository();

  bool isLoading = false;
  List<RequesttoopentshopModel> requests = [];
  RequesttoopentshopModel? currentUserRequest;
  String? errorMessage;

  ///  Gửi yêu cầu mở shop
  Future<void> createRequest(RequesttoopentshopModel request) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _repo.createRequest(request);

      requests.add(request);
      currentUserRequest = request;
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error creating request: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRequest(RequesttoopentshopModel request) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _repo.updateRequest(request);

      final index = requests.indexWhere(
        (r) => r.requestId == request.requestId,
      );
      if (index != -1) {
        requests[index] = request;
      }
      if (currentUserRequest?.requestId == request.requestId) {
        currentUserRequest = request;
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error updating request: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  Lấy tất cả yêu cầu (admin)
  Future<void> fetchAllRequests() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      requests = await _repo.getAllRequests();
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error fetching requests: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // lấy yêu cầu theo id của bảng request
  Future<RequesttoopentshopModel?> fetchRequestById(String requestId) async {
    if (requestId.isEmpty) return null;
    isLoading = true;
    notifyListeners();

    try {
      final request = await _repo.getRequestById(requestId);
      currentUserRequest = request;
      return request;
    } catch (e, st) {
      debugPrint('Error fetching request by ID: $e');
      debugPrintStack(stackTrace: st);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ///  Lấy yêu cầu theo userId (cho người dùng hiện tại)
  // Future<void> fetchRequestByUsers(String userId) async {
  //   try {
  //     isLoading = true;
  //     errorMessage = null;
  //     notifyListeners();

  //     currentUserRequest = await _repo.getRequestsByUserId(userId);
  //   } catch (e, st) {
  //     errorMessage = e.toString();
  //     debugPrint('Error fetching user request: $e\n$st');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  ///  Xóa yêu cầu
  Future<void> deleteRequest(String requestId) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.deleteRequest(requestId);
      requests.removeWhere((r) => r.requestId == requestId);
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error deleting request: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<RequesttoopentshopModel>> fetchRequestsByStatus(
    String status,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _repo.fetchRequestsByStatus(status);
      return data;
    } catch (e, st) {
      return [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateStatus(String requestId, String newStatus) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _repo.updateRequestStatus(requestId, newStatus);

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = requests[index].copyWith(status: newStatus);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error updating request status: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatusWithShop(
    String requestId,
    String newStatus,
    String shopId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _repo.updateRequestStatusWithShop(requestId, newStatus, shopId);

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = requests[index].copyWith(
          status: newStatus,
          shopId: shopId,
        );
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Error updating request status with shop: $e\n$st');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<RequesttoopentshopModel>?> fetchApprovedRequestsByUserId(
    String userId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _repo.getApprovedRequestsByUserId(userId);
      isLoading = false;
      notifyListeners();

      return data;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Stream<List<RequesttoopentshopModel>> streamUserRequests(String userId) {
    return _repo.streamRequestsByUser(userId);
  }

  /// Lấy tất cả request theo userId (trả về nhiều)
  Future<List<RequesttoopentshopModel>> fetchRequestsByUserId(
    String userId,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _repo.getRequestsByUserId(userId);
      return data;
    } catch (e, st) {
      debugPrint("Error fetchRequestsByUserId: $e\n$st");
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
