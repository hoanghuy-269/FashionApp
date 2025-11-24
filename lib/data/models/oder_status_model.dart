class OderStatusModel {
  final String oderStatusID;
  final String orderStatusName;

  OderStatusModel({required this.oderStatusID, required this.orderStatusName});
  factory OderStatusModel.fromJson(Map<String, dynamic> json) {
    return OderStatusModel(
      oderStatusID: json['oderStatusID'] as String,
      orderStatusName: json['orderStatusName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'oderStatusID': oderStatusID, 'orderStatusName': orderStatusName};
  }
}
