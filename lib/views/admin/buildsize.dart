import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/views/shop/addsize_dialog.dart';
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
  void initState() {
    super.initState();
  }

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

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...filteredSizes.map((size) {
              final isSelected = _localSelected.any((s) => s.sizeID == size.sizeID);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _localSelected.removeWhere(
                          (s) => s.sizeID == size.sizeID);
                    } else {
                      _localSelected.add(size);
                    }
                  });
                  widget.onSizeToggled?.call(size, !isSelected);
                },
                child: Container(
                  width: 40,
                  height: 40,
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
            }),
            GestureDetector(
              onTap: () async {
                final sizeName = await showDialog<String>(
                  context: context,
                  builder: (_) => const AddsizeDialog(),
                );
                if (sizeName != null && sizeName.isNotEmpty) {
                  // Kiểm tra size đã tồn tại chưa
                  final isExists = await sizeVM.isSizeNameExists(
                    sizeName,
                    widget.selectedCategory!.categoryID,
                  );

                  if (isExists) {
                    // Hiển thị thông báo nếu size đã tồn tại
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Size "$sizeName" đã tồn tại trong danh mục này!'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }

                  // Thêm size mới nếu chưa tồn tại
                  final sizeID = await sizeVM.generateSizeId();
                  final newSize = SizesModel(
                    sizeID: sizeID,
                    categoryID: widget.selectedCategory!.categoryID,
                    name: sizeName,
                  );

                  await sizeVM.addSize(newSize);

                  // Hiển thị thông báo thành công
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm size "$sizeName" thành công!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: const Icon(Icons.add, size: 20, color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
}