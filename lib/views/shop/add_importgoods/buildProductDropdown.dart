import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildProductDropdown extends StatefulWidget {
  final String brandID;
  final void Function(ProductsModel? product)? onProductSelected;

  const BuildProductDropdown({
    super.key,
    required this.brandID,
    this.onProductSelected,
  });

  @override
  State<BuildProductDropdown> createState() => _BuildProductDropdownState();
}

class _BuildProductDropdownState extends State<BuildProductDropdown> {
  List<ProductsModel> productList = [];
  ProductsModel? selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, _) {
        // Lọc theo brandID
        final filteredProducts =
            productVM.productList
                .where((p) => p.brandID == widget.brandID)
                .toList();

        // Loại bỏ trùng lặp dựa trên productID
        final uniqueProducts = <String, ProductsModel>{};
        for (var product in filteredProducts) {
          uniqueProducts[product.productID] = product;
        }
        final products = uniqueProducts.values.toList();

        // Reset selectedProduct nếu không còn trong danh sách
        if (selectedProduct != null && 
            !products.any((p) => p.productID == selectedProduct!.productID)) {
          selectedProduct = null;
        }

        if (productVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return const Text("Không có sản phẩm trong chi nhánh này");
        }

        return DropdownButtonFormField<ProductsModel>(
          decoration: const InputDecoration(
            labelText: "Chọn sản phẩm",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          value: selectedProduct,
          items:
              products.map((prod) {
                return DropdownMenuItem<ProductsModel>(
                  value: prod,
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag),
                      const SizedBox(width: 10),
                      Text(
                        prod.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (prod) {
            setState(() {
              selectedProduct = prod;
            });
            if (widget.onProductSelected != null) {
              widget.onProductSelected!(prod);
            }
          },
        );
      },
    );
  }
}