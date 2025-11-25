import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';

class DialogAddcolor extends StatefulWidget {
  const DialogAddcolor({super.key});

  @override
  State<DialogAddcolor> createState() => _DialogAddcolorState();
}

class _DialogAddcolorState extends State<DialogAddcolor> {
  final nameController = TextEditingController();
  Color selectedColor = Colors.blue;
  bool _isLoading = false;

  String get hexCode =>
      '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _addColorToDatabase(BuildContext context) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên màu'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colorVM = context.read<ColorsViewmodel>();
      
      // Gọi hàm addColor từ ColorsViewmodel
      await colorVM.addColor(name, hexCode);
      
      // Thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm màu $name'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm màu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm màu sắc'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Tên màu sắc'),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Chọn màu:'),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Chọn màu'),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() => selectedColor = color);
                            Navigator.of(context).pop();
                          },
                          availableColors: const [
                            Colors.white,
                            Colors.black,
                            Colors.red,
                            Colors.pink,
                            Colors.purple,
                            Colors.deepPurple,
                            Colors.indigo,
                            Colors.blue,
                            Colors.lightBlue,
                            Colors.cyan,
                            Colors.teal,
                            Colors.green,
                            Colors.lightGreen,
                            Colors.lime,
                            Colors.yellow,
                            Colors.amber,
                            Colors.orange,
                            Colors.deepOrange,
                            Colors.brown,
                            Colors.grey,
                            Colors.blueGrey,
                          ],   
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => _addColorToDatabase(context),
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }
}