import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildsizeShop extends StatefulWidget {
  final void Function(SizesModel size, bool selected)? onSizeToggled;

  const BuildsizeShop({super.key, this.onSizeToggled});

  @override
  State<BuildsizeShop> createState() => _BuildsizeShopState();
}

class _BuildsizeShopState extends State<BuildsizeShop> {
  final List<SizesModel> _localSelected = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SizesViewmodel>(
      builder: (context, sizeVM, child) {
        final allSizes = sizeVM.sizesList;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...allSizes.map((size) {
              final isSelected = _localSelected.any(
                (s) => s.sizeID == size.sizeID,
              );
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _localSelected.removeWhere(
                        (s) => s.sizeID == size.sizeID,
                      );
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
          ],
        );
      },
    );
  }
}
