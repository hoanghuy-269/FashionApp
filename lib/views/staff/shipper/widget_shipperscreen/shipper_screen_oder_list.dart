import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_emtyView.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_errorview.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_oderCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShipperScreenOderList extends StatelessWidget {
  final String shopID;
  final String staffID;
  final List<dynamic> Function(List<dynamic>) filterItems;
  final Set<int> expandedItems;
  final ValueChanged<int> onToggleExpand;

  const ShipperScreenOderList({super.key, 
    required this.shopID,
    required this.staffID,
    required this.filterItems,
    required this.expandedItems,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderItemViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return ShipperScreenErrorview(
            error: vm.error!,
            onRetry: () => vm.listenOrderItems(shopID),
          );
        }

        if (vm.items.isEmpty) {
          return Emtyview(
            icon: Icons.inbox,
            message: "Không có đơn hàng nào",
          );
        }

        final filtered = filterItems(vm.items);

        if (filtered.isEmpty) {
          return Emtyview(
            icon: Icons.search_off,
            message: "Không tìm thấy đơn hàng",
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            vm.listenOrderItems(shopID);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return ShipperScreenOdercard(
                item: filtered[index],
                isExpanded: expandedItems.contains(index),
                onToggle: () => onToggleExpand(index),
                staffID: staffID,
              );
            },
          ),
        );
      },
    );
  }
}
