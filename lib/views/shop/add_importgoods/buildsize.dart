import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/views/shop/addsize_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buildsize extends StatefulWidget {
  final void Function(SizesModel size, bool selected)? onSizeToggled;

  const Buildsize({super.key, this.onSizeToggled});

  @override
  State<Buildsize> createState() => _BuildsizeState();
}

class _BuildsizeState extends State<Buildsize> {
  CategoryModel? selectedCategory;
  final List<SizesModel> _localSelected = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<SizesViewmodel>(
      builder: (context, sizeVM, child) {
        final sizes = sizeVM.sizesList;

        if (sizeVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (colors.isEmpty) {
        //   return const Text("Chưa có màu nào, hãy thêm mới!");
        // }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...sizes.map((size) {
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

                  if (widget.onSizeToggled != null) {
                    widget.onSizeToggled!(size, !isSelected);
                  }
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
            // nut them moi
            GestureDetector(
              onTap: () async {
                final sizeName = await showDialog<String>(
                  context: context,
                  builder: (_) => const AddsizeDialog(),
                );
                if (sizeName != null && sizeName.isNotEmpty) {
                  // use the SizeViewModel provided by the Consumer above
                  final sizeID = await sizeVM.generateSizeId();
                  final newSize = SizesModel(
                    sizeID: sizeID,
                    categoryID: selectedCategory?.categoryID ?? "",
                    name: sizeName,
                  );

                  await sizeVM.addSize(newSize);
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
