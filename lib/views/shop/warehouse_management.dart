import 'package:fashion_app/views/shop/importgoods_warehouse_screen.dart';
import 'package:fashion_app/views/shop/shop_importgoods.dart';
import 'package:fashion_app/views/staff/shopproduct_detal_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';

class WarehouseChartScreen extends StatefulWidget {
  const WarehouseChartScreen({super.key});

  @override
  State<WarehouseChartScreen> createState() => _WarehouseChartScreenState();
}

class _WarehouseChartScreenState extends State<WarehouseChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<ShopViewModel>().currentShop?.shopId ?? '';
      context.read<ShopProductViewModel>().fetchShopProducts(shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopId = context.read<ShopViewModel>().currentShop?.shopId ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê sản phẩm bán chạy')),
      body: Consumer<ShopProductViewModel>(
        builder: (context, shopproductVM, _) {
          if (shopproductVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopproductVM.shopProducts.isEmpty) {
            return const Center(child: Text('Không có dữ liệu sản phẩm'));
          }

          final products = List<ShopProductModel>.from(
            shopproductVM.shopProducts,
          );
          products.sort((a, b) => (b.sold ?? 0).compareTo(a.sold ?? 0));
          final topProducts = products.take(5).toList();

          // Tính maxY an toàn
          final maxSold = topProducts.fold<int>(
            0,
            (max, product) =>
                (product.sold ?? 0) > max ? (product.sold ?? 0) : max,
          );
          final maxY = maxSold > 0 ? (maxSold * 1.2) : 10.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${topProducts[group.x.toInt()].name}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Đã bán: ${rod.toY.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 5,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      barGroups:
                          topProducts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (product.sold ?? 0).toDouble(),
                                  width: 20,
                                  color: Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxY / 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= topProducts.length) {
                                return const SizedBox.shrink();
                              }
                              final name = topProducts[index].name;
                              final displayName =
                                  name.length > 15
                                      ? '${name.substring(0, 12)}...'
                                      : name;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Danh sách sản phẩm
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topProducts.length,
                  itemBuilder: (context, index) {
                    final product = topProducts[index];
                    final sold = product.sold ?? 0;

                    return GestureDetector(
                      onTap: () {
                        final shopProductId = product.shopproductID;
                        if (shopProductId == null || shopProductId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Không tìm thấy ID của sản phẩm "${product.name}"',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImportgoodsWarehouseScreen(
                                  shopProductID: shopProductId,
                                )
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Nội dung chính
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text(
                                    'Đã bán: $sold',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                           
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
