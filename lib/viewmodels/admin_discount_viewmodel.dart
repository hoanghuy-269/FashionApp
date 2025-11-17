import 'package:fashion_app/data/repositories/discount_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../data/models/voucher.dart';

class AdminDiscountViewModel extends ChangeNotifier {
  final DiscountRepository _repo;
  
  AdminDiscountViewModel({DiscountRepository? repo})
      : _repo = repo ?? DiscountRepository();

  bool _initialized = false;
  List<Voucher> _vouchers = [];
  String? _error;

  bool get initialized => _initialized;
  List<Voucher> get vouchers => _vouchers;
  String? get error => _error;

  // Initializing Firebase
  Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  // Fetching all vouchers from the repository
  Future<List<Voucher>> fetch() async {
    try {
      final list = await _repo.fetchAll();
      _vouchers = list;
      _error = null;
      notifyListeners();
      return list;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Adding a new voucher
  Future<void> add(Voucher v) async {
    await _repo.add(v);
    await fetch();
  }

  // Updating an existing voucher
  Future<void> update(String id, Voucher v) async {
    await _repo.update(id, v);
    await fetch();
  }

  // Deleting a voucher
  Future<void> delete(String id) async {
    await _repo.delete(id);
    await fetch();
  }

  // Getter for discount amount (now using percentage)
  String amountString(Voucher v) => '${v.percentageDiscount}% Giảm giá';
}
