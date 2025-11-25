import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';

class BuildProductDropdown extends StatefulWidget {
  final String brandID;
  final String categoryID;
  final void Function(ProductsModel? product)? onProductSelected;

  const BuildProductDropdown({
    super.key,
    required this.brandID,
    required this.categoryID,
    this.onProductSelected,
  });

  @override
  State<BuildProductDropdown> createState() => _BuildProductDropdownState();
}

class _BuildProductDropdownState extends State<BuildProductDropdown> {
  ProductsModel? selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, _) {
        // Chỉ lọc khi brand/category có giá trị
        final categoryID =
            widget.categoryID.isNotEmpty ? widget.categoryID : null;
        final filteredProducts =
            productVM.productList.where((p) {
              final matchBrand =
                  widget.brandID.isEmpty || p.brandID == widget.brandID;
              final matchCategory =
                  categoryID == null || p.categoryID == categoryID;
              return matchBrand && matchCategory;
            }).toList();

        // Loại bỏ trùng sản phẩm
        final uniqueProducts =
            {for (var p in filteredProducts) p.productID: p}.values.toList();

        // Reset product nếu không còn trong danh sách
        if (selectedProduct != null &&
            !uniqueProducts.any(
              (p) => p.productID == selectedProduct!.productID,
            )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => selectedProduct = null);
            widget.onProductSelected?.call(null);
          });
        }

        if (productVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (uniqueProducts.isEmpty) {
          return const Text(
            "Không có sản phẩm phù hợp",
            style: TextStyle(color: Colors.grey),
          );
        }

        return DropdownButtonFormField<ProductsModel>(
          key: ValueKey(
            '${widget.brandID}_${widget.categoryID}',
          ),
          decoration: const InputDecoration(
            labelText: "Chọn sản phẩm",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          value: selectedProduct,
          isExpanded: true, // Cho phép dropdown mở rộng đầy đủ
          items: uniqueProducts.map((prod) {
            return DropdownMenuItem<ProductsModel>(
              value: prod,
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prod.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (prod) {
            setState(() => selectedProduct = prod);
            widget.onProductSelected?.call(prod);
          },
        );
      },
    );
  }
}