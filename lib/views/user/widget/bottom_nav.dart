import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:fashion_app/views/user/widget/widget.dart';
import 'package:flutter/material.dart';

class ProductOptionsBottomSheet extends StatefulWidget {
  final ShopProductWithDetail product;
  final VoidCallback onClose;
  final Function(
    ShopProductWithDetail,
    StateSetter, {
    String? selectedSize,
    int? selectedColorIndex,
    int? quantity,
  })
  onAddToCart; // Sửa signature
  final Function(GlobalKey) onAddToCartAnimation;
  final Function(String selectedSize, int selectedColorIndex, int quantity)
  onBuyNow;
  const ProductOptionsBottomSheet({
    required this.product,
    required this.onClose,
    required this.onAddToCart,
    required this.onAddToCartAnimation,
    required this.onBuyNow,
  });

  @override
  State<ProductOptionsBottomSheet> createState() =>
      _ProductOptionsBottomSheetState();
}

class _ProductOptionsBottomSheetState extends State<ProductOptionsBottomSheet> {
  String selectedSize = "";
  String selectedColor = "";
  int _quantity = 0;
  int selectedColorIndex = 0;
  List<Map<String, dynamic>> sizes = [];
  bool _isLoadingSizes = true;
  final ProductDetailHelper _helper = ProductDetailHelper();
  final GlobalKey _addToCartButtonKey = GlobalKey();
  final ValueNotifier<int> quantityNotifier = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    if (!_helper.isSizeCacheLoaded) {
      await _helper.loadAllSizes();
    }
    _loadSizesForVariant();
  }

  void _loadSizesForVariant() {
    if (widget.product.variants.isEmpty) return;

    final variantID =
        widget.product.variants[selectedColorIndex].shopProductVariantID;
    final productID = widget.product.shopProduct.shopproductID;

    _helper
        .listenSizesByVariant(productID: productID, variantID: variantID)
        .listen((loadedSizes) {
          if (mounted) {
            setState(() {
              sizes = loadedSizes;
              _isLoadingSizes = false;
            });
          }
        });
  }

  void _onColorSelected(int index) {
    setState(() {
      selectedColorIndex = index;
      selectedSize = "";
      _isLoadingSizes = true;
      quantityNotifier.value = 0;
    });
    _loadSizesForVariant();
  }

  void _onSizeSelected(String sizeID) {
    setState(() {
      selectedSize = sizeID;
    });
    quantityNotifier.value = 0;
  }

  void _onQuantityChanged(int quantity) {
    quantityNotifier.value = quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.product.variants.isNotEmpty &&
                              widget.product.variants[0].imageUrls.isNotEmpty
                          ? widget.product.variants[0].imageUrls
                          : "https://via.placeholder.com/150",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey.shade400);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.productDetail.name ?? "Không có tên",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Hiển thị giá - sử dụng widget riêng
                      _PriceDisplayWidget(
                        product: widget.product,
                        selectedSize: selectedSize,
                        selectedColorIndex: selectedColorIndex,
                        helper: _helper,
                      ),
                      const SizedBox(height: 4),
                      // Hiển thị stock - sử dụng widget riêng
                      _StockDisplayWidget(
                        product: widget.product,
                        selectedSize: selectedSize,
                        selectedColorIndex: selectedColorIndex,
                        helper: _helper,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Màu sắc
                  _buildColorSelection(widget.product),
                  const SizedBox(height: 20),

                  // Kích thước - sử dụng widget riêng
                  _SizeSelectionWidget(
                    product: widget.product,
                    selectedSize: selectedSize,
                    selectedColorIndex: selectedColorIndex,
                    onSizeSelected: _onSizeSelected,
                    helper: _helper,
                  ),
                  const SizedBox(height: 20),

                  QuantitySelectorWidget(
                    key: ValueKey(
                      'quantity_${widget.product.shopProduct.shopproductID}',
                    ),
                    selectedSize: selectedSize,
                    sizes: sizes,
                    helper: _helper,
                    onQuantityChanged: _onQuantityChanged,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Action Buttons
          ValueListenableBuilder<int>(
            valueListenable: quantityNotifier,
            builder: (context, quantity, _) {
              return _ActionButtonsWidget(
                product: widget.product,
                selectedSize: selectedSize,
                selectedColorIndex: selectedColorIndex,
                quantity: quantity, // 🔥 quantity đúng
                onAddToCart: widget.onAddToCart,
                helper: _helper,
                onAddToCartAnimation: widget.onAddToCartAnimation,
                addToCartButtonKey: _addToCartButtonKey,
                onBuyNow: widget.onBuyNow,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection(ShopProductWithDetail product) {
    return ColorSelectionWidget(
      variants: product.variants,
      selectedColorIndex: selectedColorIndex,
      onColorSelected: _onColorSelected,
      helper: _helper,
    );
  }
}

class _PriceDisplayWidget extends StatelessWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final int selectedColorIndex;
  final ProductDetailHelper helper;

  const _PriceDisplayWidget({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.helper,
  });

  Stream<List<Map<String, dynamic>>> _getSizesStream(
    ShopProductWithDetail product,
  ) {
    if (product.variants.isEmpty) {
      return Stream.value([]);
    }

    final variantID = product.variants[selectedColorIndex].shopProductVariantID;
    final productID = product.shopProduct.shopproductID;

    return helper.listenSizesByVariant(
      productID: productID,
      variantID: variantID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getSizesStream(product),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            helper.formatPrice(product.lowestPrice),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final currentSizes = snapshot.data!;
          final price =
              selectedSize.isEmpty
                  ? helper.getMinPrice(currentSizes)
                  : helper.getSizePrice(selectedSize, currentSizes);

          return Text(
            helper.formatPrice(price),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        return Text(
          helper.formatPrice(product.lowestPrice),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class _StockDisplayWidget extends StatelessWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final int selectedColorIndex;
  final ProductDetailHelper helper;

  const _StockDisplayWidget({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.helper,
  });

  Stream<List<Map<String, dynamic>>> _getSizesStream(
    ShopProductWithDetail product,
  ) {
    if (product.variants.isEmpty) {
      return Stream.value([]);
    }

    final variantID = product.variants[selectedColorIndex].shopProductVariantID;
    final productID = product.shopProduct.shopproductID;

    return helper.listenSizesByVariant(
      productID: productID,
      variantID: variantID,
    );
  }

  double _getSelectedSizeStock(List<Map<String, dynamic>> currentSizes) {
    if (selectedSize.isEmpty) return 0;

    for (final size in currentSizes) {
      if (size['sizeID'] == selectedSize) {
        return (size['quantity'] as num).toDouble();
      }
    }
    return 0;
  }

  double _getCurrentVariantStock(List<Map<String, dynamic>> currentSizes) {
    double total = 0;
    for (final size in currentSizes) {
      total += (size['quantity'] as num).toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getSizesStream(product),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Kho: Đang tải...",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final currentSizes = snapshot.data!;
          final stock =
              selectedSize.isEmpty
                  ? _getCurrentVariantStock(currentSizes)
                  : _getSelectedSizeStock(currentSizes);

          return Text(
            "Kho: ${stock.toInt()}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          );
        }

        return Text(
          "Kho: 0",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        );
      },
    );
  }
}

class _SizeSelectionWidget extends StatefulWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final int selectedColorIndex;
  final Function(String) onSizeSelected;
  final ProductDetailHelper helper;

  const _SizeSelectionWidget({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.onSizeSelected,
    required this.helper,
  });

  @override
  State<_SizeSelectionWidget> createState() => _SizeSelectionWidgetState();
}

class _SizeSelectionWidgetState extends State<_SizeSelectionWidget> {
  Stream<List<Map<String, dynamic>>> _getSizesStream(
    ShopProductWithDetail product,
  ) {
    if (product.variants.isEmpty) {
      return Stream.value([]);
    }

    final variantID =
        product.variants[widget.selectedColorIndex].shopProductVariantID;
    final productID = product.shopProduct.shopproductID;

    return widget.helper.listenSizesByVariant(
      productID: productID,
      variantID: variantID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kích thước",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getSizesStream(widget.product),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Đang tải sizes...'),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Không có size nào cho màu này');
            }

            final currentSizes = snapshot.data!;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  currentSizes.map((size) {
                    final sizeID = size['sizeID'] as String;
                    final sizeName = widget.helper.getSizeName(
                      sizeID,
                      currentSizes,
                    );
                    final quantity = size['quantity'] as int;
                    final price = (size['price'] as num).toDouble();
                    final isSelected = sizeID == widget.selectedSize;

                    return GestureDetector(
                      onTap:
                          quantity > 0
                              ? () => widget.onSizeSelected(sizeID)
                              : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              quantity > 0
                                  ? (isSelected
                                      ? Colors.blueAccent
                                      : Colors.grey.shade200)
                                  : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              sizeName,
                              style: TextStyle(
                                color:
                                    quantity > 0
                                        ? (isSelected
                                            ? Colors.white
                                            : Colors.black)
                                        : Colors.white70,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButtonsWidget extends StatelessWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final int selectedColorIndex;
  final int quantity;
  final Function(GlobalKey) onAddToCartAnimation;
  final GlobalKey addToCartButtonKey;
  final Function(
    ShopProductWithDetail,
    StateSetter, {
    String? selectedSize,
    int? selectedColorIndex,
    int? quantity,
  })
  onAddToCart;
  final ProductDetailHelper helper;
  final Function(String selectedSize, int selectedColorIndex, int quantity)
  onBuyNow; // Sửa signature

  const _ActionButtonsWidget({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.quantity,
    required this.onAddToCart,
    required this.helper,
    required this.addToCartButtonKey,
    required this.onAddToCartAnimation,
    required this.onBuyNow, // Sửa
  });

  int _getSelectedSizeStock(List<Map<String, dynamic>> sizes) {
    for (final s in sizes) {
      if (s['sizeID'] == selectedSize) {
        return (s['quantity'] as num).toInt();
      }
    }
    return 0;
  }

  Stream<List<Map<String, dynamic>>> _getSizesStream(
    ShopProductWithDetail product,
  ) {
    if (product.variants.isEmpty) return Stream.value([]);

    final variantID = product.variants[selectedColorIndex].shopProductVariantID;
    final productID = product.shopProduct.shopproductID;

    return helper.listenSizesByVariant(
      productID: productID,
      variantID: variantID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getSizesStream(product),
      builder: (context, snapshot) {
        final hasSizes = snapshot.hasData && snapshot.data!.isNotEmpty;
        final isSizeSelected = selectedSize.isNotEmpty;
        int selectedStock = 0;
        if (isSizeSelected && hasSizes) {
          selectedStock = _getSelectedSizeStock(snapshot.data!);
        }

        final isQuantityValid = quantity > 0; // Sửa thành > 0 thay vì >= 0
        final isEnabled =
            hasSizes && isSizeSelected && isQuantityValid && selectedStock > 0;

        // XÓA phần ẩn đi - luôn hiển thị nút
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              // NÚT THÊM VÀO GIỎ HÀNG
              Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isEnabled) // Chỉ có shadow khi enabled
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: ElevatedButton(
                  key: addToCartButtonKey,
                  onPressed:
                      isEnabled
                          ? () {
                            onAddToCartAnimation(addToCartButtonKey);
                            onAddToCart(
                              product,
                              (fn) {},
                              selectedSize: selectedSize,
                              selectedColorIndex: selectedColorIndex,
                              quantity: quantity,
                            );
                          }
                          : null, // null = disabled (mờ đi)
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnabled ? Colors.orangeAccent : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // NÚT MUA NGAY
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isEnabled) // Chỉ có shadow khi enabled
                        BoxShadow(
                          color: const Color(0xFF007AFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        isEnabled
                            ? () {
                              // THÊM VÀO GIỎ HÀNG TRƯỚC
                              onAddToCart(
                                product,
                                (fn) {},
                                selectedSize: selectedSize,
                                selectedColorIndex: selectedColorIndex,
                                quantity: quantity,
                              );

                              // SAU ĐÓ CHUYỂN ĐẾN CHECKOUT
                              onBuyNow(
                                selectedSize,
                                selectedColorIndex,
                                quantity,
                              );
                            }
                            : null, // null = disabled (mờ đi)
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            isEnabled
                                ? const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 234, 133, 102),
                                    Color.fromARGB(255, 162, 75, 75),
                                  ],
                                )
                                : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500,
                                  ],
                                ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "MUA NGAY",
                          style: TextStyle(
                            color:
                                isEnabled ? Colors.white : Colors.grey.shade200,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
