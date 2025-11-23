import 'dart:io';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class OrderConfirmationDialog extends StatefulWidget {
  final String staffID;
  final String oderitemID;
  final String oderID;
  const OrderConfirmationDialog({
    super.key,
    required this.oderitemID,
    required this.staffID,
    required this.oderID,
  });

  @override
  State<OrderConfirmationDialog> createState() =>
      _OrderConfirmationDialogState();
}

class _OrderConfirmationDialogState extends State<OrderConfirmationDialog> {
  File? selectedImage;
  final TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleConfirmOrder(bool isReceived) async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh minh chứng trước khi xác nhận'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final oderVM = context.read<OrderItemViewModel>();

    setState(() {
      isLoading = true;
    });

    try {
      String? imageUrl = await oderVM.uploadDeliveryProof(
        selectedImage!,
        widget.oderID,
      );

      final newStatus = isReceived ? "status_004" : "status_005";
      await oderVM.updateOrderItemStatus(widget.oderitemID, newStatus);

      await oderVM.updateOrderShipper(
        widget.oderID,
        shipperId: widget.staffID,
        cancellationReason:
            noteController.text.isNotEmpty ? noteController.text : null,
        deliveryProofUrl: imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isReceived ? 'Xác nhận khách nhận thành công' : 'Đã hủy đơn hàng',
            ),
            backgroundColor: isReceived ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Spacer để cân đối
                  const Text(
                    'Xác nhận đơn hàng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image picker
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        showPickImageBottomSheet(context).then((file) {
                          if (file != null) {
                            setState(() {
                              selectedImage = file;
                            });
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedImage == null ? Colors.red : Colors.grey.shade400,
                      width: selectedImage == null ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    color: Colors.grey.shade100,
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 50, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              'Chụp ảnh đơn hàng *',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '(Bắt buộc)',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Note field
              TextField(
                controller: noteController,
                enabled: !isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'Nhập ghi chú / lý do nếu có',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (isLoading) const CircularProgressIndicator(),

              const SizedBox(height: 12),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: isLoading ? null : () => _handleConfirmOrder(true),
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'Khách nhận',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: isLoading ? null : () => _handleConfirmOrder(false),
                      icon: const Icon(Icons.cancel),
                      label: const Text(
                        'Khách hủy',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
