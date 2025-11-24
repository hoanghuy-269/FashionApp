import 'package:fashion_app/data/models/address.dart';
import 'package:fashion_app/data/sources/address_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressScreen extends StatefulWidget {
  final String userId;
  const AddressScreen({required this.userId});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];

  List<Map<String, dynamic>> filteredProvinces = [];
  List<Map<String, dynamic>> filteredDistricts = [];
  List<Map<String, dynamic>> filteredWards = [];

  Map<String, dynamic>? selectedProvince;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedWard;

  final detailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final provinceSearchController = TextEditingController();
  final districtSearchController = TextEditingController();
  final wardSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProvinces();
  }

  Future<void> loadProvinces() async {
    try {
      provinces =
          (await AddressService.getProvinces()).cast<Map<String, dynamic>>();
      filteredProvinces = List<Map<String, dynamic>>.from(provinces);
      setState(() {});
    } catch (e) {
      print('Error loading provinces: $e');
    }
  }

  Future<void> loadDistricts() async {
    if (selectedProvince == null) return;

    try {
      final provinceCode = selectedProvince!["code"];
      districts =
          (await AddressService.getDistricts(
            provinceCode,
          )).cast<Map<String, dynamic>>();
      filteredDistricts = List<Map<String, dynamic>>.from(districts);
      filteredDistricts = List.from(districts);
      wards.clear();
      filteredWards.clear();
      selectedDistrict = null;
      selectedWard = null;
      districtSearchController.clear();
      wardSearchController.clear();
      setState(() {});
    } catch (e) {
      print('Error loading districts: $e');
    }
  }

  Future<void> loadWards() async {
    if (selectedDistrict == null) return;

    try {
      final districtCode = selectedDistrict!["code"];
      wards =
          (await AddressService.getWards(
            districtCode,
          )).cast<Map<String, dynamic>>();
      filteredWards = List<Map<String, dynamic>>.from(wards);
      filteredWards = List.from(wards);
      selectedWard = null;
      wardSearchController.clear();
      setState(() {});
    } catch (e) {
      print('Error loading wards: $e');
    }
  }

  void filterProvinces(String query) {
    setState(() {
      filteredProvinces =
          provinces.where((province) {
            final name = province["name"]?.toString().toLowerCase() ?? "";
            return name.contains(query.toLowerCase());
          }).toList();
    });
  }

  void filterDistricts(String query) {
    setState(() {
      filteredDistricts =
          districts.where((district) {
            final name = district["name"]?.toString().toLowerCase() ?? "";
            return name.contains(query.toLowerCase());
          }).toList();
    });
  }

  void filterWards(String query) {
    setState(() {
      filteredWards =
          wards.where((ward) {
            final name = ward["name"]?.toString().toLowerCase() ?? "";
            return name.contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> saveAddress() async {
    if (selectedProvince == null ||
        selectedDistrict == null ||
        selectedWard == null ||
        detailController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    // Validate số điện thoại
    final phoneRegex = RegExp(r'^(0|\+84)(\d{9,10})$');
    if (!phoneRegex.hasMatch(phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ")),
      );
      return;
    }

    final addressData = {
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "detail": detailController.text.trim(),
      "ward": selectedWard!["name"],
      "district": selectedDistrict!["name"],
      "province": selectedProvince!["name"],
      "isDefault": false, // Mới thêm sẽ không phải mặc định
      "timestamp": FieldValue.serverTimestamp(), // Sử dụng server timestamp
    };

    try {
      // Lưu Firestore - CHỈ 1 LẦN
      final docRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("addresses")
          .add(addressData);

      // Trả về Address object - CHỈ 1 LẦN Navigator.pop
      final newAddress = Address(
        id: docRef.id,
        name: addressData["name"]!,
        phone: addressData["phone"]!,
        detail: addressData["detail"]!,
        ward: addressData["ward"]!,
        district: addressData["district"]!,
        province: addressData["province"]!,
        isDefault: false,
        createdAt: Timestamp.now(),
      );

      // CHỈ GỌI Navigator.pop 1 LẦN
      Navigator.pop(context, newAddress);
    } catch (e) {
      print('Error saving address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra khi lưu địa chỉ")),
      );
    }
  }

  // HÀM HIỂN THỊ TEXT ĐÃ CHỌN - ĐÃ THÊM VÀO ĐÂY
  String _getProvinceDisplayText() =>
      selectedProvince?["name"]?.toString() ?? "";
  String _getDistrictDisplayText() =>
      selectedDistrict?["name"]?.toString() ?? "";
  String _getWardDisplayText() => selectedWard?["name"]?.toString() ?? "";

  Widget _buildSearchableDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> filteredItems,
    required TextEditingController searchController,
    required Map<String, dynamic>? selectedValue,
    required Function(Map<String, dynamic>?) onChanged,
    required Function(String) onSearch,
    required String Function() getDisplayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Hiển thị giá trị đã chọn
              if (selectedValue != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getDisplayText(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm $label...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  onChanged: onSearch,
                ),
              ),

              // Danh sách kết quả
              if (filteredItems.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        title: Text(
                          item["name"]?.toString() ?? "",
                          style: TextStyle(fontSize: 14),
                        ),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        onTap: () {
                          onChanged(item);
                          searchController.clear();
                          onSearch('');
                        },
                      );
                    },
                  ),
                )
              else if (searchController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Không tìm thấy kết quả',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Địa chỉ giao hàng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin người nhận
              Text(
                "Thông tin người nhận",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Tên người nhận
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),

              // Số điện thoại
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: "0xxx xxx xxx",
                ),
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 24),
              Text(
                "Địa chỉ giao hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Tỉnh/Thành phố với tìm kiếm
              _buildSearchableDropdown(
                label: "Tỉnh / Thành phố",
                items: provinces,
                filteredItems: filteredProvinces,
                searchController: provinceSearchController,
                selectedValue: selectedProvince,
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                  });
                  loadDistricts();
                },
                onSearch: filterProvinces,
                getDisplayText: _getProvinceDisplayText, // SỬA Ở ĐÂY
              ),

              SizedBox(height: 16),

              // Quận/Huyện với tìm kiếm
              _buildSearchableDropdown(
                label: "Quận / Huyện",
                items: districts,
                filteredItems: filteredDistricts,
                searchController: districtSearchController,
                selectedValue: selectedDistrict,
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                  loadWards();
                },
                onSearch: filterDistricts,
                getDisplayText: _getDistrictDisplayText, // SỬA Ở ĐÂY
              ),

              SizedBox(height: 16),

              // Xã/Phường với tìm kiếm
              _buildSearchableDropdown(
                label: "Xã / Phường",
                items: wards,
                filteredItems: filteredWards,
                searchController: wardSearchController,
                selectedValue: selectedWard,
                onChanged: (value) {
                  setState(() {
                    selectedWard = value;
                  });
                },
                onSearch: filterWards,
                getDisplayText: _getWardDisplayText, // SỬA Ở ĐÂY
              ),

              SizedBox(height: 16),

              // Địa chỉ chi tiết
              TextField(
                controller: detailController,
                decoration: InputDecoration(
                  labelText: "Số nhà, tên đường, tòa nhà, ...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
              ),

              SizedBox(height: 32),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "LƯU ĐỊA CHỈ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    provinceSearchController.dispose();
    districtSearchController.dispose();
    wardSearchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    super.dispose();
  }
}
