import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  final VoidCallback onBuy;

  const ProductItem({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ảnh sản phẩm
          Container(
            height: 100,
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              image:
                  imageUrl.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 6),
          // Tên sản phẩm
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          // Giá + đánh giá
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${price.toStringAsFixed(0)}₫",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(rating.toString(), style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          // Nút mua ngay
          ElevatedButton.icon(
            onPressed: onBuy,
            icon: const Icon(Icons.shopping_cart, size: 16),
            label: const Text("Mua ngay"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
