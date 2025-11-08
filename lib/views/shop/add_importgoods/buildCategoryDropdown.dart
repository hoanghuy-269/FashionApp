import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buildcategorydropdown extends StatefulWidget {
  final void Function(CategoryModel? category)? onCategorySelected;

  const Buildcategorydropdown({super.key, this.onCategorySelected});

  @override
  State<Buildcategorydropdown> createState() => _BuildcategorydropdownState();
}

class _BuildcategorydropdownState extends State<Buildcategorydropdown> {
  List<CategoryModel> categoryList = [];
  CategoryModel? selectedCategory;
  SizesModel? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewmodel>(
      builder: (context, cateVM, child) {
        final category = cateVM.categoryList;
        if (cateVM.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (category.isEmpty) {
          return Text(" Không có danh mục");
        }
        return DropdownButtonFormField<CategoryModel>(
          decoration: InputDecoration(
            labelText: "Chọn danh mục",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          value: selectedCategory,
          items:
              category.map((cate) {
                return DropdownMenuItem<CategoryModel>(
                  value: cate,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(cate.logoUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cate.categoryName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              selectedSize = null;
            });

            if (widget.onCategorySelected != null)
              widget.onCategorySelected!(value);

            if (value != null) {
              final SizeVM = Provider.of<SizesViewmodel>(
                context,
                listen: false,
              );
              SizeVM.fetchSizes(value.categoryID);
            }
          },
        );
      },
    );
  }
}
