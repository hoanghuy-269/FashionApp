class StorestaffModel {
  final String employeeId;
  final String shopId;
  final String fullName;
  final String? phoneNumber;
  final String nameaccount;
  final String password;
  final String roleIds;
  final String? nationalId; // căn cước công dận
  final String? nationalIdFront; // mặt trước căn cước công dân
  final String? nationalIdBack; // mặt sau căn cước công dân
  final DateTime createdAt;

  StorestaffModel({
    required this.employeeId,
    required this.shopId,
    required this.fullName,
    this.phoneNumber,
    required this.nameaccount,
    required this.password,
    required this.roleIds,
    this.nationalId,
    this.nationalIdFront,
    this.nationalIdBack,
    required this.createdAt,
  });

  factory StorestaffModel.fromMap(Map<String, dynamic> map) {
    return StorestaffModel(
      employeeId: map['employeeId'],
      shopId: map['shopId'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      nameaccount: map['nameaccount'],
      password: map['password'],
      roleIds: map['roleIds'],
      nationalId: map['nationalId'],
      nationalIdFront: map['nationalIdFront'],
      nationalIdBack: map['nationalIdBack'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'shopId': shopId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'nameaccount': nameaccount,
      'password': password,
      'roleIds': roleIds,
      'nationalId': nationalId,
      'nationalIdFront': nationalIdFront,
      'nationalIdBack': nationalIdBack,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
