import 'package:fashion_app/core/location/provinceService.dart';
import 'package:fashion_app/data/models/location/district_model.dart';
import 'package:fashion_app/data/models/location/province_model.dart';
import 'package:fashion_app/data/models/location/ward_model.dart';
import 'package:flutter/material.dart';

class ProvincedropdowCreen extends StatefulWidget {
  const ProvincedropdowCreen({super.key});

  @override
  State<ProvincedropdowCreen> createState() => _ProvincedropdowCreenState();
}

class _ProvincedropdowCreenState extends State<ProvincedropdowCreen> {
  List<ProvinceModel> provinces = [];
  ProvinceModel? selectedProvince;
  District? selectedDistrict;
  WardModel? selectedWard;


  void loadProvinces() async {
    final data = await ProvinceService.getAllProvinces();
    setState(() {
      provinces = data;
    });
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn địa chỉ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown Tỉnh
            DropdownButton<ProvinceModel>(
              hint: const Text('Chọn Tỉnh/TP'),
              value: selectedProvince,
              isExpanded: true,
              items: provinces.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                );
              }).toList(),
              onChanged: (p) {
                setState(() {
                  selectedProvince = p;
                  selectedDistrict = null;
                  selectedWard = null;
                });
              },
            ),

            // Dropdown Quận/Huyện
            DropdownButton<District>(
              hint: const Text('Chọn Quận/Huyện'),
              value: selectedDistrict,
              isExpanded: true,
              items: selectedProvince?.districts.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: (d) {
                setState(() {
                  selectedDistrict = d;
                  selectedWard = null;
                });
              },
            ),

            // Dropdown Phường/Xã
            DropdownButton<WardModel>(
              hint: const Text('Chọn Phường/Xã'),
              value: selectedWard,
              isExpanded: true,
              items: selectedDistrict?.wards.map((w) {
                return DropdownMenuItem(
                  value: w,
                  child: Text(w.name),
                );
              }).toList(),
              onChanged: (w) {
                setState(() {
                  selectedWard = w;
                });
              },
            ),

            const SizedBox(height: 20),
            if (selectedProvince != null &&
                selectedDistrict != null &&
                selectedWard != null)
              Text(
                'Địa chỉ: ${selectedWard!.name}, ${selectedDistrict!.name}, ${selectedProvince!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}