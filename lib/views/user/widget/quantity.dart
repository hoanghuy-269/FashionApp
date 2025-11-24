import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final String selectedSize;
  final List<Map<String, dynamic>> sizes;
  final ProductDetailHelper helper;
  final Function(int) onQuantityChanged;

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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _quantity = 0;
  }

  void _updateQuantity(int newQuantity) {
    if (_isUpdating) {
      print('🚫 Đang update, bỏ qua');
      return;
    }
    _isUpdating = true;

    final oldQuantity = _quantity;
    print('🔄 UPDATE: $oldQuantity -> $newQuantity');
    print(
      '📊 Max quantity: ${widget.selectedSize.isEmpty ? 0 : widget.helper.getSizeQuantity(widget.selectedSize, widget.sizes)}',
    );

    if (newQuantity < 0) {
      print('❌ Số lượng < 1');
      _isUpdating = false;
      return;
    }

    final maxQuantity =
        widget.selectedSize.isEmpty
            ? 0
            : widget.helper.getSizeQuantity(widget.selectedSize, widget.sizes);

    if (newQuantity > maxQuantity) {
      print('❌ Vượt quá số lượng tối đa: $newQuantity > $maxQuantity');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số lượng tối đa là $maxQuantity')),
      );
      _isUpdating = false;
      return;
    }

    setState(() {
      _quantity = newQuantity;
    });

    print('✅ Đã cập nhật: $_quantity');
    widget.onQuantityChanged(_quantity);

    Future.delayed(const Duration(milliseconds: 300), () {
      _isUpdating = false;
      print('🔄 Reset update flag');
    });
  }

  void _incrementQuantity() {
    _updateQuantity(_quantity + 1);
  }

  void _decrementQuantity() {
    _updateQuantity(_quantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    final maxQuantity =
        widget.selectedSize.isEmpty
            ? 0
            : widget.helper.getSizeQuantity(widget.selectedSize, widget.sizes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Số lượng",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút giảm - GỌI PHƯƠNG THỨC RIÊNG
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: _quantity > 0 ? _decrementQuantity : null,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.all(8),
                ),
              ),

              // Số lượng
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Nút tăng - GỌI PHƯƠNG THỨC RIÊNG
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: _quantity < maxQuantity ? _incrementQuantity : null,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),

        if (maxQuantity > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Còn $maxQuantity sản phẩm',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
