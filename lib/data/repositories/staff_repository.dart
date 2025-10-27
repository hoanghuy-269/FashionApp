import 'package:fashion_app/data/models/storestaff_model.dart';

class StaffRepositories {

  final StaffRepositories _remoteDataSource = StaffRepositories();

  Future<void> addStaff(StorestaffModel staff) => _remoteDataSource.addStaff(staff);
  Future<void> updateStaff(StorestaffModel staff) => _remoteDataSource.updateStaff(staff);

  Future<List<StorestaffModel>> getStaffs() => _remoteDataSource.getStaffs();

  Future<StorestaffModel?> getStaffById(String employeeId) => _remoteDataSource.getStaffById(employeeId);

  Future<List<StorestaffModel>> getStaffsByShop(String shopId) => _remoteDataSource.getStaffsByShop(shopId);

  Future<void> deleteStaff(String employeeId) => _remoteDataSource.deleteStaff(employeeId);
}