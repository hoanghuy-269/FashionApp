import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DialogAddcolor extends StatefulWidget {
  const DialogAddcolor({super.key});

  @override
  State<DialogAddcolor> createState() => _DialogAddcolorState();
}

class _DialogAddcolorState extends State<DialogAddcolor> {
  final nameController = TextEditingController();
  Color selectedColor = Colors.blue; // màu mặc định

  String get hexCode =>
      '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

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
                builder:
                    (_) => AlertDialog(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            final colorData = {'name': name, 'hexCode': hexCode};
            print('Thêm màu: $colorData');

            Navigator.pop(context, colorData);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
