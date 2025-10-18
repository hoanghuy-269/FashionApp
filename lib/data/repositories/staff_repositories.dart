import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/data/sources/staff_remotesources.dart';

class StaffRepositories {

  final StaffRemotesources _remoteDataSource = StaffRemotesources();

  Future<void> addStaff(ShopstaffModel staff) => _remoteDataSource.addStaff(staff);

  Future<List<ShopstaffModel>> getStaffs() => _remoteDataSource.getStaffs();

  Future<ShopstaffModel?> getStaffById(String employeeId) => _remoteDataSource.getStaffById(employeeId);
}