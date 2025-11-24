import 'dart:async';

import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/views/user/product_detail.dart';
import 'package:flutter/material.dart';

class BestSellingBanner extends StatefulWidget {
  final List<ShopProductWithDetail> products;
  final String? idUser;

  const BestSellingBanner({super.key, required this.products, this.idUser});

  @override
  State<BestSellingBanner> createState() => _BestSellingBannerState();
}

class _BestSellingBannerState extends State<BestSellingBanner> {
  late List<ShopProductWithDetail> _topItems;
  int _currentIndex = 0;
  final PageController _controller = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prepareBanner();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant BestSellingBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _prepareBanner();
      setState(() {});
    }
  }

  void _prepareBanner() {
    final sorted = [...widget.products];
    sorted.sort(
      (a, b) => (b.shopProduct.sold ?? 0).compareTo(a.shopProduct.sold ?? 0),
    );

    _topItems = sorted.take(4).toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients && _topItems.length > 1) {
        final next = (_currentIndex + 1) % _topItems.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _currentIndex = next);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_topItems.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: _topItems.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final item = _topItems[index];
              final imageUrl =
                  item.shopProduct.imageUrls.isNotEmpty
                      ? item.shopProduct.imageUrls
                      : "https://via.placeholder.com/150";

              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductDetailScreen(
                              product: item,
                              idUser: widget.idUser,
                            ),
                      ),
                    ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),

                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productDetail.name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Từ ${_formatPrice(item.lowestPrice)}đ",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _topItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == index ? 12 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentIndex == index ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) return "${(price / 1000).toStringAsFixed(0)}k";
    return price.toStringAsFixed(0);
  }
}
