import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:fashion_app/data/sources/staff_remotesources.dart';

class StorestaffsRepositories {

  final StaffRemotesources _remoteDataSource = StaffRemotesources();

  Future<void> addStaff(StorestaffModel staff) => _remoteDataSource.addStaff(staff);
  Future<void> updateStaff(StorestaffModel staff) => _remoteDataSource.updateStaff(staff);

  Future<List<StorestaffModel>> getStaffs() => _remoteDataSource.getStaffs();

  Future<StorestaffModel?> getStaffById(String employeeId) => _remoteDataSource.getStaffById(employeeId);

  Future<List<StorestaffModel>> getStaffsByShop(String shopId) => _remoteDataSource.getStaffsByShop(shopId);

  Future<void> deleteStaff(String shopId, String employeeId) => _remoteDataSource.deleteStaff(shopId, employeeId);

  Future<bool> isStaffEmailExists(String email, String shopId) => _remoteDataSource.isStaffEmailExists(email,shopId);
  
}