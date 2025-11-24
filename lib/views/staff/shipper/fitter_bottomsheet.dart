// Bottom Sheet Filter Widget
import 'package:flutter/material.dart';

class FitterBottomsheet extends StatefulWidget {
  final String selectedDistrict;
  final String sortBy;
  final Function(String district, String sort) onApply;

  const FitterBottomsheet({
    required this.selectedDistrict,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<FitterBottomsheet> createState() => FitterBottomsheetState();
}

class FitterBottomsheetState extends State<FitterBottomsheet> {
  late String _tempDistrict;
  late String _tempSort;

  // Danh sách quận/huyện của TP.HCM - bạn có thể tùy chỉnh
  final List<String> districts = [
    'Tất cả',
    'Quận 1',
    'Quận 2',
    'Quận 3',
    'Quận 4',
    'Quận 5',
    'Quận 6',
    'Quận 7',
    'Quận 8',
    'Quận 9',
    'Quận 10',
    'Quận 11',
    'Quận 12',
    'Thủ Đức',
    'Bình Thạnh',
    'Tân Bình',
    'Tân Phú',
    'Phú Nhuận',
    'Gò Vấp',
    'Bình Tân',
  ];

  @override
  void initState() {
    super.initState();
    _tempDistrict = widget.selectedDistrict;
    _tempSort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lọc theo khu vực
          const Text(
            'Khu vực giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: districts.length,
              itemBuilder: (context, index) {
                final district = districts[index];
                return RadioListTile<String>(
                  title: Text(district),
                  value: district,
                  groupValue: _tempDistrict,
                  onChanged: (value) {
                    setState(() {
                      _tempDistrict = value!;
                    });
                  },
                );
              },
            ),
          ),
          const Divider(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _tempDistrict = 'Tất cả';
                      _tempSort = 'Mới nhất';
                    });
                  },
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_tempDistrict, _tempSort);
                    Navigator.pop(context);
                  },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
