import 'package:flutter/material.dart';
import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';

// ==================== IMAGE SLIDER ====================
class ProductImageSlider extends StatefulWidget {
  final List<String> productImages;
  final PageController pageController;
  final int currentImage;
  final ValueChanged<int> onPageChanged;
  final GlobalKey imageKey;

  const ProductImageSlider({
    super.key,
    required this.productImages,
    required this.pageController,
    required this.currentImage,
    required this.onPageChanged,
    required this.imageKey,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: widget.productImages.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder:
                (context, index) => Container(
                  key: index == widget.currentImage ? widget.imageKey : null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: Image.network(
                    widget.productImages[index],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => _buildErrorImage(),
                    loadingBuilder:
                        (context, child, loadingProgress) =>
                            loadingProgress == null
                                ? child
                                : _buildLoadingImage(loadingProgress),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.productImages.length > 1) _buildPageIndicator(),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 50, color: Colors.red),
          SizedBox(height: 8),
          Text('Lỗi tải ảnh', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingImage(ImageChunkEvent? loadingProgress) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        value:
            loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.productImages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: widget.currentImage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                widget.currentImage == index ? Colors.blueAccent : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ==================== COLOR SELECTION ====================
class ColorSelectionWidget extends StatefulWidget {
  final List<ShopProductVariantModel> variants;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;
  final ProductDetailHelper helper;

  const ColorSelectionWidget({
    super.key,
    required this.variants,
    required this.selectedColorIndex,
    required this.onColorSelected,
    required this.helper,
  });

  @override
  State<ColorSelectionWidget> createState() => _ColorSelectionWidgetState();
}

class _ColorSelectionWidgetState extends State<ColorSelectionWidget> {
  Map<String, String> _colorNames = {}; // Cache tên màu
  Map<String, bool> _loadingColors = {}; // Theo dõi màu đang load

  @override
  void initState() {
    super.initState();
    _loadColorNames();
  }

  // Load tên màu cho tất cả variants
  Future<void> _loadColorNames() async {
    for (var variant in widget.variants) {
      if (!_colorNames.containsKey(variant.colorID) &&
          !_loadingColors.containsKey(variant.colorID)) {
        setState(() {
          _loadingColors[variant.colorID] = true;
        });

        final colorName = await widget.helper.getColorName(variant.colorID);

        setState(() {
          _colorNames[variant.colorID] = colorName;
          _loadingColors.remove(variant.colorID);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Màu sắc",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.variants.length, (index) {
            final variant = widget.variants[index];
            final isSelected = index == widget.selectedColorIndex;
            final isLoading = _loadingColors[variant.colorID] == true;
            final colorName = _colorNames[variant.colorID] ?? 'Đang tải...';

            return GestureDetector(
              onTap: () => widget.onColorSelected(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child:
                            variant.imageUrls.isNotEmpty
                                ? Image.network(
                                  variant.imageUrls,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          _buildColorErrorImage(index),
                                )
                                : _buildColorPlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Hiển thị tên màu từ Firebase
                    isLoading
                        ? SizedBox(
                          width: 60,
                          height: 16,
                          child: Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                        : Text(
                          colorName, // CHỈ HIỂN THỊ TÊN MÀU, KHÔNG CÓ ID
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected ? Colors.blueAccent : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildColorErrorImage(int index) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.grey[600], size: 20),
          Text(
            "Màu ${index + 1}",
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(Icons.photo, color: Colors.grey[500], size: 20),
    );
  }
}

// ==================== SIZE SELECTION ====================
class SizeSelectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sizes;
  final String selectedSize;
  final ValueChanged<String> onSizeSelected;
  final bool isLoading;
  final ProductDetailHelper helper;

  const SizeSelectionWidget({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.isLoading,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kích thước",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        isLoading
            ? _buildSizeLoading()
            : sizes.isEmpty
            ? const Text('Không có size nào cho màu này')
            : _buildSizeOptions(),
      ],
    );
  }

  Widget _buildSizeLoading() {
    return const Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 10),
        Text('Đang tải sizes...'),
      ],
    );
  }

  Widget _buildSizeOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children:
          sizes.map((size) {
            final sizeID = size['sizeID'] as String;
            final sizeName = size['name'] as String;
            final quantity = size['quantity'] as int;
            final isSelected = sizeID == selectedSize;

            return GestureDetector(
              onTap: quantity > 0 ? () => onSizeSelected(sizeID) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      quantity > 0
                          ? (isSelected
                              ? Colors.blueAccent
                              : const Color(0xFFD9D9D9))
                          : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sizeName,
                  style: TextStyle(
                    color:
                        quantity > 0
                            ? (isSelected ? Colors.white : Colors.black)
                            : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ==================== QUANTITY SELECTOR ====================
class QuantitySelectorWidget extends StatefulWidget {
  final String selectedSize;
  final List<Map<String, dynamic>> sizes;
  final ProductDetailHelper helper;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelectorWidget({
    super.key,
    required this.selectedSize,
    required this.sizes,
    required this.helper,
    required this.onQuantityChanged,
  });

  @override
  State<QuantitySelectorWidget> createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    final maxQuantity = widget.helper.getSizeQuantity(
      widget.selectedSize,
      widget.sizes,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Số lượng:", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        _buildQuantityButton(
          icon: Icons.remove,
          isEnabled: _quantity > 0,
          onTap: () {
            setState(() => _quantity--);
            widget.onQuantityChanged(_quantity);
          },
          color:
              _quantity > 0
                  ? const Color.fromARGB(255, 245, 131, 131)
                  : Colors.grey[300]!,
        ),
        const SizedBox(width: 10),
        Container(
          width: 45,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: TextEditingController(text: '$_quantity')
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: '$_quantity'.length),
              ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              int? num = int.tryParse(value);
              if (num == null || num <= 0) {
                setState(() => _quantity = 0);
              } else if (num > maxQuantity) {
                setState(() => _quantity = maxQuantity);
              } else {
                setState(() => _quantity = num);
              }
              widget.onQuantityChanged(_quantity);
            },
          ),
        ),
        const SizedBox(width: 10),
        _buildQuantityButton(
          icon: Icons.add,
          isEnabled: widget.selectedSize.isNotEmpty && _quantity < maxQuantity,
          onTap: () {
            if (widget.selectedSize.isNotEmpty && _quantity < maxQuantity) {
              setState(() => _quantity++);
              widget.onQuantityChanged(_quantity);
            }
          },
          color:
              widget.selectedSize.isEmpty
                  ? Colors.grey[300]!
                  : (_quantity < maxQuantity
                      ? const Color.fromARGB(255, 118, 200, 238)
                      : Colors.grey[300]!),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey[500],
          size: 18,
        ),
      ),
    );
  }
}

// ==================== ACTION BUTTONS ====================
class ProductActionButtons extends StatelessWidget {
  final String selectedSize;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final GlobalKey addToCartButtonKey;
  final int quantity;

  const ProductActionButtons({
    super.key,
    required this.selectedSize,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.addToCartButtonKey,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Nút giỏ hàng với hiệu ứng đẹp
          Container(
            width: 60,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  selectedSize.isNotEmpty
                      ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: ElevatedButton(
              key: addToCartButtonKey,
              onPressed:
                  (selectedSize.isNotEmpty && quantity > 0)
                      ? onAddToCart
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedSize.isNotEmpty
                        ? Colors.orangeAccent
                        : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    selectedSize.isNotEmpty
                        ? [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: ElevatedButton(
                onPressed:
                    (selectedSize.isNotEmpty && quantity > 0) ? onBuyNow : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                        selectedSize.isNotEmpty
                            ? const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 234, 133, 102),
                                Color.fromARGB(255, 243, 61, 61),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                            : LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade400,
                              ],
                            ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "MUA NGAY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT DESCRIPTION ====================
class ProductDescriptionWidget extends StatelessWidget {
  final String? description;
  final String? brandName;
  final String? shopAddress;
  final bool isLoadingAdditionalInfo;

  const ProductDescriptionWidget({
    super.key,
    required this.description,
    required this.brandName,
    required this.shopAddress,
    required this.isLoadingAdditionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        "Thông số & mô tả",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null) ...[
                const Text(
                  "Chi tiết sản phẩm:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
              ],

              // Thông tin kho hàng
              _buildInfoItem("📦 Kho", "Còn hàng"),
              const SizedBox(height: 8),

              // Thương hiệu
              isLoadingAdditionalInfo
                  ? _buildInfoItem("🏷️ Thương hiệu", "Đang tải...")
                  : brandName != null
                  ? _buildInfoItem("🏷️ Thương hiệu", brandName!)
                  : const SizedBox(),
              const SizedBox(height: 8),

              // Địa chỉ shop
              isLoadingAdditionalInfo
                  ? _buildInfoItem("🏪 Địa chỉ shop", "Đang tải...")
                  : shopAddress != null
                  ? _buildInfoItem("🏪 Địa chỉ shop", shopAddress!)
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

// ==================== PRODUCT INFO CARD ====================
class ProductInfoCard extends StatelessWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final List<Map<String, dynamic>> sizes;
  final bool isLoadingSizes;
  final ProductDetailHelper helper;

  const ProductInfoCard({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.sizes,
    required this.isLoadingSizes,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.productDetail.name ?? "Không có tên",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Price and Sold
          Row(
            children: [
              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedSize.isEmpty
                      ? helper.getFormattedMinPrice(sizes)
                      : helper.getFormattedSizePrice(selectedSize, sizes),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),

              // Sold Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Đã bán: ${product.shopProduct.sold ?? 0}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.shopProduct.rating ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "(${product.shopProduct.sold ?? 0} đánh giá)",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
