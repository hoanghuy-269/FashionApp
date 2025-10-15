import 'package:fashion_app/views/shop/shop_addemploy_creen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShopEmploymanagementScreen extends StatefulWidget {
  const ShopEmploymanagementScreen({super.key});

  @override
  State<ShopEmploymanagementScreen> createState() =>
      _ShopEmploymanagementScreenState();
}

class _ShopEmploymanagementScreenState
    extends State<ShopEmploymanagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Quản lí nhân viên ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ShopAddemployCreen(),
              );
            },
            icon: Icon(Icons.add),
            color: Colors.black,
            iconSize: 30,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // thanh tìm kiếm
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.search),
                    hintText: "Tìm kiếm nhân viên ...",
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                child: Text(
                  "Tổng nhân viên : 5",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(
                          "Nguyên Văn A",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text("Chức vụ : Nhân viên thu ngân"),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(LucideIcons.moreHorizontal),
                          onSelected: (value) {
                            if (value == "edit") {
                             showDialog(context: context, builder: (_)=> ShopAddemployCreen());
                            } else if (value == "delete") {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Xác nhận xóa"),
                                      content: const Text(
                                        "Bạn có chắc muốn xóa nhân viên này không?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("Hủy"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Xử lý xóa ở đây
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Xóa",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: "edit",
                                  child: Text("Chỉnh sửa"),
                                ),
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Text(" Xóa"),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
