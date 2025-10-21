import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/data/sources/staff_remotesources.dart';

class StaffRepositories {

  final StaffRemotesources _remoteDataSource = StaffRemotesources();

  Future<void> addStaff(ShopstaffModel staff) => _remoteDataSource.addStaff(staff);
  Future<void> updateStaff(ShopstaffModel staff) => _remoteDataSource.updateStaff(staff);

  Future<List<ShopstaffModel>> getStaffs() => _remoteDataSource.getStaffs();

  Future<ShopstaffModel?> getStaffById(String employeeId) => _remoteDataSource.getStaffById(employeeId);

  Future<List<ShopstaffModel>> getStaffsByShop(String shopId) => _remoteDataSource.getStaffsByShop(shopId);

  Future<void> deleteStaff(String employeeId) => _remoteDataSource.deleteStaff(employeeId);
}