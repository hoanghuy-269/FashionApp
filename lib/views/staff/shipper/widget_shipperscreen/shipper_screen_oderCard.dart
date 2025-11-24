import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_oderDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShipperScreenOdercard extends StatelessWidget {
  final dynamic item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String staffID;

  const ShipperScreenOdercard({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.staffID,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OrderItemViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            title: FutureBuilder<String>(
              future: vm.getUserNameCached(item.parentOrder?.userId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Text(
                  snapshot.data ?? 'Khách hàng',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "SĐT ${item.parentOrder?.customerPhone ?? 'N/A'}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item.totalPrice.toStringAsFixed(0)}đ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
          if (isExpanded)
            ShipperScreenOderdetail(item: item, staffID: staffID),
        ],
      ),
    );
  }
}
