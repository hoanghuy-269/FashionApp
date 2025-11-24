import 'package:fashion_app/data/models/location/district_model.dart';
import 'package:fashion_app/data/models/location/province_model.dart';
import 'package:fashion_app/data/models/location/ward_model.dart';
import 'package:flutter/material.dart';

class ShipperScreenLocationfillter extends StatelessWidget {
  final List<ProvinceModel> provinces;
  final ProvinceModel? selectedProvince;
  final District? selectedDistrict;
  final WardModel? selectedWard;
  final ValueChanged<ProvinceModel?> onProvinceChanged;
  final ValueChanged<District?> onDistrictChanged;
  final ValueChanged<WardModel?> onWardChanged;
  final VoidCallback onReset;

  const ShipperScreenLocationfillter({super.key, 
    required this.provinces,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedWard,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Lọc theo địa điểm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown<ProvinceModel>(
            hint: 'Chọn Tỉnh/TP',
            value: selectedProvince,
            items: provinces,
            itemLabel: (p) => p.name,
            onChanged: onProvinceChanged,
          ),
          if (selectedProvince != null) ...[
            const SizedBox(height: 12),
            _buildDropdown<District>(
              hint: 'Chọn Quận/Huyện',
              value: selectedDistrict,
              items: selectedProvince!.districts,
              itemLabel: (d) => d.name,
              onChanged: onDistrictChanged,
            ),
          ],
          if (selectedDistrict != null) ...[
            const SizedBox(height: 12),
            _buildDropdown<WardModel>(
              hint: 'Chọn Phường/Xã',
              value: selectedWard,
              items: selectedDistrict!.wards,
              itemLabel: (w) => w.name,
              onChanged: onWardChanged,
            ),
          ],
          if (selectedProvince != null || selectedDistrict != null || selectedWard != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Đặt lại bộ lọc'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(itemLabel(item)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
