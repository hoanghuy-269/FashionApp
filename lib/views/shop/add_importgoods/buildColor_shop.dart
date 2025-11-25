import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/views/admin/dialog_addcolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildcolorShop extends StatefulWidget {
  final void Function(List<ColorsModel> selectedColors)? onColorsSelected;

  const BuildcolorShop({super.key, this.onColorsSelected});

  @override
  State<BuildcolorShop> createState() => _BuildcolorShopState();
}

class _BuildcolorShopState extends State<BuildcolorShop> {
  final List<ColorsModel> _localSelected = [];
  @override
  Widget build(BuildContext context) {
   return Consumer<ColorsViewmodel>(
      builder: (context, colorVM, child) {
        final colors = colorVM.colors;

        if (colorVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (colors.isEmpty) {
        //   return const Text("Chưa có màu nào, hãy thêm mới!");
        // }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...colors.map((color) {
              final colorValue = Color(
                int.parse(color.hexCode.substring(1), radix: 16) + 0xFF000000,
              );
              final isSelected = _localSelected.any((c) => c.colorID == color.colorID);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _localSelected.removeWhere((c) => c.colorID == color.colorID);
                    } else {
                      _localSelected.add(color);
                    }
                  });

                  if (widget.onColorsSelected != null) {
                    widget.onColorsSelected!(_localSelected);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}