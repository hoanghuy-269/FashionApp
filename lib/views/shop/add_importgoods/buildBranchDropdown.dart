import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buildbranchdropdown extends StatefulWidget {
  final void Function(BrandsModel? brand)? onBrandSelected;

  const Buildbranchdropdown({super.key, this.onBrandSelected});

  @override
  State<Buildbranchdropdown> createState() => _BuildbranchdropdownState();
}

class _BuildbranchdropdownState extends State<Buildbranchdropdown> {
    BrandsModel? selectedBrand;

    List<BrandsModel> brandList = [];

  @override
  Widget build(BuildContext context) {
   return Consumer<BrandViewmodel>(
      builder: (context, brandVM, child) {
        final brands = brandVM.brands;
        if (brandVM.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (brands.isEmpty) {
          return Text(" Không có thương hiệu");
        }
        return DropdownButtonFormField<BrandsModel>(
          decoration: InputDecoration(
            labelText: "Chọn thương hiệu",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never
          ),
          value: selectedBrand,
          items:
              brands.map((brand) {
                return DropdownMenuItem<BrandsModel>(
                  value: brand,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(brand.logoUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        brand.name,
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
              selectedBrand = value;
              if (widget.onBrandSelected != null) widget.onBrandSelected!(value);
            });
          },
        );
      },
    );
  }
}