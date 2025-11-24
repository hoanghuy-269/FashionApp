import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddsizeDialog extends StatefulWidget {
  final CategoryModel selectedCategory;

  const AddsizeDialog({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<AddsizeDialog> createState() => _AddsizeDialogState();
}

class _AddsizeDialogState extends State<AddsizeDialog> {
  final TextEditingController _sizeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.straighten,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Thêm Size Mới',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục: ${widget.selectedCategory.categoryName}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _sizeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Tên Size',
              hintText: 'Ví dụ: S, M, L, XL, XXL...',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.shade700,
                  width: 2,
                ),
              ),
            ),
            enabled: !_isLoading,
            onSubmitted: (_) => _handleAddSize(),
          ),
        ],
      ),
      actions: [
        // Nút Hủy
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),

        // Nút Thêm
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAddSize,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }

  Future<void> _handleAddSize() async {
    final sizeName = _sizeController.text.trim().toUpperCase();

    // Validate
    if (sizeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên size!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sizeVM = context.read<SizesViewmodel>();

      // 1. Kiểm tra size đã tồn tại chưa
      final isExists = await sizeVM.isSizeNameExists(
        sizeName,
        widget.selectedCategory.categoryID,
      );

      if (isExists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Size "$sizeName" đã tồn tại trong danh mục này!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // 2. Tạo size mới
      final sizeID = await sizeVM.generateSizeId();
      final newSize = SizesModel(
        sizeID: sizeID,
        categoryID: widget.selectedCategory.categoryID,
        name: sizeName,
      );

      // 3. LƯU VÀO DATABASE
      await sizeVM.addSize(newSize);

      if (!mounted) return;

      // 4. Đóng dialog và thông báo thành công
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Đã thêm size "$sizeName" thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm size: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}