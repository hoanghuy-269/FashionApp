import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  // ✅ Upload ảnh lên Firebase Storage
  Future<String> uploadImageToFirebase(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('categories/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ✅ Dialog thêm danh mục với UI đẹp hơn
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    File? pickedImg;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Thêm danh mục",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Tên danh mục",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: pickedImg != null
                        ? Image.file(pickedImg!, fit: BoxFit.cover)
                        : const Center(child: Text("Chưa chọn ảnh")),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Chọn ảnh"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final img = await showPickImageBottomSheet(context);
                    if (img != null) {
                      setState(() => pickedImg = img);
                    }
                  },
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Hủy"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty) return;

                          String imageUrl = "";
                          if (pickedImg != null) {
                            imageUrl = await uploadImageToFirebase(pickedImg!);
                          }

                          await FirebaseFirestore.instance.collection('categories').add({
                            'categoryName': nameCtrl.text,
                            'logoUrl': imageUrl,
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Lưu"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Dialog sửa với UI đẹp
  void _showEditDialog(String id, String name, String logo) {
    final nameCtrl = TextEditingController(text: name);
    File? newImg;
    String currentLogo = logo;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cập nhật danh mục",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Tên danh mục",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: newImg != null
                        ? Image.file(newImg!, fit: BoxFit.cover)
                        : currentLogo.isNotEmpty
                            ? Image.network(currentLogo, fit: BoxFit.cover)
                            : const Center(child: Text("Chưa có ảnh")),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Đổi ảnh"),
                  onPressed: () async {
                    final img = await showPickImageBottomSheet(context);
                    if (img != null) {
                      setState(() => newImg = img);
                    }
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Hủy"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          String newUrl = currentLogo;

                          if (newImg != null) {
                            newUrl = await uploadImageToFirebase(newImg!);
                          }

                          await FirebaseFirestore.instance
                              .collection('categories')
                              .doc(id)
                              .update({
                            'categoryName': nameCtrl.text.trim(),
                            'logoUrl': newUrl,
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Lưu"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Xóa danh mục
  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa danh mục"),
        content: const Text("Bạn có chắc muốn xóa danh mục này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('categories').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showAddDialog,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 190,
            ),
            itemBuilder: (_, i) {
              var d = docs[i].data() as Map<String, dynamic>;
              var id = docs[i].id;

              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onLongPress: () => _showEditDialog(id, d['categoryName'], d['logoUrl']),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              d['logoUrl'] != "" ? NetworkImage(d['logoUrl']) : null,
                          child: d['logoUrl'] == ""
                              ? const Icon(Icons.image, size: 32)
                              : null,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          d['categoryName'],
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
