import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buildsize extends StatefulWidget {
  final void Function(SizesModel size, bool selected)? onSizeToggled;
  final CategoryModel? selectedCategory;

  const Buildsize({super.key, this.onSizeToggled, this.selectedCategory});

  @override
  State<Buildsize> createState() => _BuildsizeState();
}

class _BuildsizeState extends State<Buildsize> {
  final List<SizesModel> _localSelected = [];

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return Consumer<SizesViewmodel>(
      builder: (context, sizeVM, child) {
        final allSizes = sizeVM.sizesList;
        final filteredSizes = allSizes
            .where((size) => size.categoryID == widget.selectedCategory!.categoryID)
            .toList();

        if (sizeVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Nếu không có size nào
        if (filteredSizes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Chưa có size nào. Vui lòng thêm size ở phần "Thêm Size" bên trên!',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }

        // Hiển thị danh sách sizes
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredSizes.map((size) {
            final isSelected = _localSelected.any((s) => s.sizeID == size.sizeID);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _localSelected.removeWhere((s) => s.sizeID == size.sizeID);
                  } else {
                    _localSelected.add(size);
                  }
                });
                widget.onSizeToggled?.call(size, !isSelected);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    size.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}