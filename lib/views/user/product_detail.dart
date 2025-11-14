import 'dart:async';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final String userId;

  const ProductDetailScreen({super.key, required this.userId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImage = 0;
  late PageController _pageController;
  Timer? _timer;

  int selectedColorIndex = 0;
  String selectedSize = "M";

  // Danh sách tên ảnh mô phỏng
  final List<String> productImages = ['Ảnh 1', 'Ảnh 2', 'Ảnh 3'];

  // Danh sách tên màu
  final List<String> colorImages = ['Đen', 'Xám', 'Be'];

  final List<String> sizes = ["M", "L", "XL", "2XL"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentImage + 1;
        if (nextPage >= productImages.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ẢNH SẢN PHẨM ===
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: productImages.length,
                        onPageChanged: (index) {
                          setState(() => _currentImage = index);
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[300],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              productImages[index],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Chấm chuyển ảnh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        productImages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _currentImage == index
                                    ? Colors.blueAccent
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === TÊN & GIÁ ===
              const Text(
                "Áo Thun Tealab Local Brand Unisex Hà Nội Trà Bã T-Shirt",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Giá: ",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Text(
                    "50.000 đ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Đã bán: 12",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // === SỐ LƯỢNG ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Số lượng:", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap:
                        _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.remove, color: Colors.white, size: 18),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () => setState(() => _quantity++),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // === MÀU SẮC ===
              const Text(
                "Màu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(colorImages.length, (index) {
                  final isSelected = index == selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColorIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300], // Màu nền cho hình ảnh
                          alignment: Alignment.center,
                          child: Text(
                            colorImages[index],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // === SIZE ===
              const Text(
                "Kích thước",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children:
                    sizes.map((size) {
                      final isSelected = size == selectedSize;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blueAccent
                                    : const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),
              const SizedBox(height: 10),
              ExpansionTile(
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
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("📦 Chất liệu: cotton"),
                        const SizedBox(height: 8),
                        const Text("📦 Kho: còn hàng"),
                        const SizedBox(height: 8),
                        const Text("📦 Thương hiệu: Teelab"),
                        const SizedBox(height: 8),
                        const Text("📦 Địa chỉ shop: Thành phố Hồ Chí Minh"),
                        const SizedBox(height: 16),
                        const Text(
                          "Chào mừng bạn đến với cửa hàng thương hiệu VERDANT",
                        ),
                        const SizedBox(height: 8),
                        const Text("Mô tả sản phẩm:"),
                        const SizedBox(height: 8),
                        const Text("• Chất liệu: 100% cotton, 200g"),
                        const SizedBox(height: 4),
                        const Text("• Màu sắc: Đen, xám, be"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // === ĐÁNH GIÁ SẢN PHẨM ===
              const Text(
                "4.1 ⭐ Đánh giá sản phẩm (2)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "thongDB",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "⭐ ⭐ ⭐ ⭐ ⭐",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ],
                  ),
                  const Text("Sản phẩm ố trong tầm giá"),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        "Huy DB",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "⭐ ⭐ ⭐ ⭐",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("1"),
                ],
              ),
              // === NÚT MUA NGAY ===
              // === NÚT MUA NGAY VÀ THÊM VÀO GIỎ HÀNG ===
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Đã thêm $_quantity sản phẩm size $selectedSize, màu ${selectedColorIndex + 1} vào giỏ hàng.",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Đã thêm $_quantity sản phẩm size $selectedSize, màu ${selectedColorIndex + 1} vào giỏ hàng.",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Mua ngay",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
