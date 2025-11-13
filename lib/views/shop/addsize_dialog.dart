import 'package:flutter/material.dart';

class AddsizeDialog extends StatefulWidget {
  const AddsizeDialog({super.key});

  @override
  State<AddsizeDialog> createState() => _AddsizeDialogState();
}

class _AddsizeDialogState extends State<AddsizeDialog> {
  final TextEditingController _sizeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm Size Mới'),
      content: TextField(
        controller: _sizeController,
        decoration: const InputDecoration(hintText: 'Nhập tên size'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final sizeName  = _sizeController.text.trim();
            if (sizeName.isNotEmpty) {
              Navigator.of(context).pop(sizeName);
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}