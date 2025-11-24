import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static const String baseUrl = "https://provinces.open-api.vn/api/";

  /// Lấy danh sách tỉnh/thành phố
  static Future<List<dynamic>> getProvinces() async {
    final response = await http.get(Uri.parse("${baseUrl}p/"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  /// Lấy danh sách quận/huyện theo tỉnh - xử lý cả String và int
  static Future<List<dynamic>> getDistricts(dynamic provinceCode) async {
    // Chuyển đổi thành int nếu là String
    final int code;
    if (provinceCode is String) {
      code = int.tryParse(provinceCode) ?? 0;
    } else if (provinceCode is int) {
      code = provinceCode;
    } else {
      code = 0;
    }

    if (code == 0) return [];

    final response = await http.get(Uri.parse("${baseUrl}p/$code?depth=2"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["districts"] ?? [];
    } else {
      throw Exception('Failed to load districts');
    }
  }

  /// Lấy danh sách phường/xã theo huyện - xử lý cả String và int
  static Future<List<dynamic>> getWards(dynamic districtCode) async {
    // Chuyển đổi thành int nếu là String
    final int code;
    if (districtCode is String) {
      code = int.tryParse(districtCode) ?? 0;
    } else if (districtCode is int) {
      code = districtCode;
    } else {
      code = 0;
    }

    if (code == 0) return [];

    final response = await http.get(Uri.parse("${baseUrl}d/$code?depth=2"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["wards"] ?? [];
    } else {
      throw Exception('Failed to load wards');
    }
  }

  /// Lấy tên tỉnh/thành phố từ code - xử lý cả String và int
  static Future<String> getProvinceName(dynamic provinceCode) async {
    try {
      final int code;
      if (provinceCode is String) {
        code = int.tryParse(provinceCode) ?? 0;
      } else if (provinceCode is int) {
        code = provinceCode;
      } else {
        code = 0;
      }

      if (code == 0) return "Unknown Province";

      final response = await http.get(Uri.parse("${baseUrl}p/$code"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["name"] ?? "Unknown Province";
      }
      return "Unknown Province";
    } catch (e) {
      return "Unknown Province";
    }
  }

  /// Lấy tên quận/huyện từ code - xử lý cả String và int
  static Future<String> getDistrictName(dynamic districtCode) async {
    try {
      final int code;
      if (districtCode is String) {
        code = int.tryParse(districtCode) ?? 0;
      } else if (districtCode is int) {
        code = districtCode;
      } else {
        code = 0;
      }

      if (code == 0) return "Unknown District";

      final response = await http.get(Uri.parse("${baseUrl}d/$code"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["name"] ?? "Unknown District";
      }
      return "Unknown District";
    } catch (e) {
      return "Unknown District";
    }
  }

  /// Lấy tên phường/xã từ code - xử lý cả String và int
  static Future<String> getWardName(dynamic wardCode) async {
    try {
      final int code;
      if (wardCode is String) {
        code = int.tryParse(wardCode) ?? 0;
      } else if (wardCode is int) {
        code = wardCode;
      } else {
        code = 0;
      }

      if (code == 0) return "Unknown Ward";

      final response = await http.get(Uri.parse("${baseUrl}w/$code"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["name"] ?? "Unknown Ward";
      }
      return "Unknown Ward";
    } catch (e) {
      return "Unknown Ward";
    }
  }
}
