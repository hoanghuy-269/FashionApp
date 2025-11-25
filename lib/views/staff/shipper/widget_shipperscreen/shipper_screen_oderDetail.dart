import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_detai_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShipperScreenOderdetail extends StatelessWidget {
  final dynamic item;
  final String staffID;

  const ShipperScreenOderdetail({super.key, required this.item, required this.staffID});
  @override
  Widget build(BuildContext context) {
    final colorVM = context.watch<ColorsViewmodel>();
    final sizeVM = context.watch<SizesViewmodel>();
    final vm = context.read<OrderItemViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetaiRow(
            icon: Icons.shopping_bag,
            label: "Mã đơn hàng",
            value: item.parentOrder?.orderId ?? 'N/A',
          ),
          const SizedBox(height: 10),
          DetaiRow(
            icon: Icons.inventory_2,
            label: "Số lượng",
            value: item.quantity.toString(),
          ),
          const SizedBox(height: 10),
          FutureBuilder<String?>(
            future: colorVM.fetchColorName(item.colorId),
            builder: (context, snapshot) {
              return DetaiRow(
                icon: Icons.color_lens,
                label: "Màu sắc",
                value: snapshot.data ?? "Không xác định",
              );
            },
          ),
          const SizedBox(height: 10),
          FutureBuilder<String?>(
            future: sizeVM.getSizeNameById(item.sizeId),
            builder: (context, snapshot) {
              return DetaiRow(
                icon: Icons.straighten,
                label: "Kích thước",
                value: snapshot.data ?? "Không xác định",
              );
            },
          ),
          const SizedBox(height: 10),
          DetaiRow(
            icon: Icons.location_on,
            label: "Địa chỉ",
            value: item.parentOrder?.customerAddress ?? 'N/A',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await vm.updateOrderItemStatus(item.orderItemId, "status_003");
                  await vm.updateOrderShipper(
                    item.parentOrder?.orderId ?? '',
                    shipperId: staffID,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã nhận đơn thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Nhận đơn', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}