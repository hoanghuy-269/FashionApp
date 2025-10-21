// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fashion_app/data/models/voucher.dart';  // Đảm bảo model Voucher đã đúng

// class AdminDiscountScreen extends StatefulWidget {
//   const AdminDiscountScreen({super.key});

//   @override
//   State<AdminDiscountScreen> createState() => _AdminDiscountScreenState();
// }

// class _AdminDiscountScreenState extends State<AdminDiscountScreen> {
//   final DatabaseReference _discountRef = FirebaseDatabase.instance.ref().child('discounts');  // Firebase Reference
//   List<Voucher> vouchers = [];  // Danh sách voucher từ Firebase

//   @override
//   void initState() {
//     super.initState();
//     _initializeFirebase();  // Khởi tạo Firebase
//   }

//   // Khởi tạo Firebase
//   Future<void> _initializeFirebase() async {
//     try {
//       await Firebase.initializeApp();  // Khởi tạo Firebase trước khi sử dụng
//       _fetchDiscounts(); // Lấy dữ liệu khi màn hình khởi tạo
//       _createSampleData();  // Tạo dữ liệu mẫu nếu bảng chưa có
//     } catch (e, st) {
//       // In lỗi rõ ràng kèm stack trace
//       print("[_initializeFirebase] Error initializing Firebase: $e");
//       print(st);
//     }
//   }

//   // Lấy danh sách voucher từ Firebase
//   Future<List<Voucher>> _fetchDiscounts() async {
//     try {
//       final snapshot = await _discountRef.get();
//       if (snapshot.exists) {
//         Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
//         final list = data.entries.map((e) {
//           return Voucher.fromMap(Map<String, dynamic>.from(e.value));
//         }).toList();
//         setState(() {
//           vouchers = list;
//         });
//         return list;  // Trả về danh sách Voucher
//       } else {
//         setState(() {
//           vouchers = [];  // Nếu không có dữ liệu, trả về danh sách rỗng
//         });
//         return [];  // Trả về danh sách rỗng
//       }
//     } catch (e, st) {
//       print("[_fetchDiscounts] Error fetching discounts: $e");
//       print(st);
//       return [];  // Nếu có lỗi, trả về danh sách rỗng
//     }
//   }

//   // Thêm voucher vào Firebase
//   Future<void> _addVoucher(Voucher voucher) async {
//     try {
//       final newVoucherRef = _discountRef.push();  // Tạo một document mới
//       print("[_addVoucher] Attempting to push voucher to Firebase...");
//       await newVoucherRef.set(voucher.toMap());
//       print("[_addVoucher] Voucher added successfully: ${voucher.toMap()}");

//       // Sau khi thêm voucher, lấy lại dữ liệu mới từ Firebase và cập nhật màn hình
//       _fetchDiscounts();
//     } catch (e, st) {
//       print("[_addVoucher] Error adding voucher: $e");
//       print(st);
//     }
//   }

//   // Cập nhật voucher trong Firebase
//   Future<void> _updateVoucher(String key, Voucher updatedVoucher) async {
//     try {
//       print("[_updateVoucher] Attempting to update voucher with key: $key");
//       await _discountRef.child(key).update(updatedVoucher.toMap());
//       print("[_updateVoucher] Voucher updated successfully with key: $key");

//       // Lấy lại dữ liệu mới từ Firebase sau khi cập nhật
//       _fetchDiscounts();
//     } catch (e, st) {
//       print("[_updateVoucher] Error updating voucher: $e");
//       print(st);
//     }
//   }

//   // Xóa voucher trong Firebase
//   Future<void> _deleteDiscount(String key) async {
//     try {
//       print("[_deleteDiscount] Attempting to delete voucher with key: $key");
//       await _discountRef.child(key).remove();
//       print("[_deleteDiscount] Voucher deleted successfully with key: $key");

//       // Lấy lại dữ liệu mới từ Firebase sau khi xóa
//       _fetchDiscounts();
//     } catch (e, st) {
//       print("[_deleteDiscount] Error deleting voucher: $e");
//       print(st);
//     }
//   }

//   // Tạo dữ liệu mẫu nếu chưa có voucher nào
//   Future<void> _createSampleData() async {
//     try {
//       final snapshot = await _discountRef.get();
//       if (!snapshot.exists) {
//         // Chỉ tạo dữ liệu mẫu nếu chưa có dữ liệu nào trong bảng discounts
//         final newVoucherRef = _discountRef.push();  // Tạo một document mới
//         final sampleVoucher = Voucher(
//           code: 'SALE20',
//           name: 'Giảm 20% cho tất cả đơn hàng',
//           amount: '20%',
//         );
//         await newVoucherRef.set(sampleVoucher.toMap());  // Đẩy voucher mẫu vào Firebase
//         print("[_createSampleData] Sample voucher added to Firebase");
//       }
//     } catch (e, st) {
//       print("[_createSampleData] Error creating sample data: $e");
//       print(st);
//     }
//   }

//   // ===== Dialogs cho thêm và sửa voucher =====
//   Future<void> _openDiscountDialog({int? index, Voucher? discount}) async {
//     final isEdit = index != null;
//     final formKey = GlobalKey<FormState>();
//     final codeCtl = TextEditingController(text: isEdit ? discount?.code : "");
//     final nameCtl = TextEditingController(text: isEdit ? discount?.name : "");
//     final amountCtl = TextEditingController(text: isEdit ? discount?.amount : "");

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text(isEdit ? 'Sửa mã giảm giá' : 'Thêm mã giảm giá'),
//           content: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: codeCtl,
//                   decoration: const InputDecoration(
//                     labelText: 'Mã',
//                     hintText: 'VD: SALE10',
//                     prefixIcon: Icon(Icons.confirmation_number_outlined),
//                   ),
//                   textCapitalization: TextCapitalization.characters,
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã' : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: nameCtl,
//                   decoration: const InputDecoration(
//                     labelText: 'Tên',
//                     hintText: 'VD: Giảm 10% cho tất cả đơn',
//                     prefixIcon: Icon(Icons.label_important_outline),
//                   ),
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: amountCtl,
//                   decoration: const InputDecoration(
//                     labelText: 'Số tiền giảm',
//                     hintText: 'VD: 10.000đ hoặc 20%',
//                     prefixIcon: Icon(Icons.sell_outlined),
//                   ),
//                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.%đĐ\s]'))],
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số tiền' : null,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
//             ElevatedButton(
//               onPressed: () {
//                 if (!formKey.currentState!.validate()) return;
//                 final data = Voucher(
//                   code: codeCtl.text.trim(),
//                   name: nameCtl.text.trim(),
//                   amount: amountCtl.text.trim(),
//                 );
//                 if (isEdit) {
//                   _updateVoucher(discount!.code, data);
//                 } else {
//                   _addVoucher(data);
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text(isEdit ? 'Lưu' : 'Thêm'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ===== Confirm Delete Dialog =====
//   Future<void> _confirmDelete(int index) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Xóa mã giảm giá'),
//         content: Text('Bạn có chắc muốn xóa "${vouchers[index].code}"?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
//           FilledButton.tonal(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Xóa'),
//           ),
//         ],
//       ),
//     );
//     if (ok == true) {
//       _deleteDiscount(vouchers[index].code);  // Xóa voucher
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F5F7),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ===== AppBar =====
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isTablet ? 20 : 12,
//                 vertical: isTablet ? 18 : 14,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: const Text(
//                       'Quản lý mã giảm giá',
//                       style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: .2),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Tooltip(
//                     message: 'Thêm mã',
//                     child: FilledButton.icon(
//                       style: FilledButton.styleFrom(backgroundColor: const Color.fromARGB(255, 78, 139, 223)),
//                       onPressed: _openDiscountDialog,
//                       icon: const Icon(Icons.add),
//                       label: const Text('Thêm'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),

//             // ===== Danh sách mã giảm giá =====
//             Expanded(
//               child: FutureBuilder<List<Voucher>>(
//                 future: _fetchDiscounts(),  // Lấy voucher từ Firebase
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Lỗi: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text('Không có mã giảm giá'));
//                   }

//                   return ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       final item = snapshot.data![index];
//                       return DiscountCard(
//                         isTablet: isTablet,
//                         code: item.code,
//                         name: item.name,
//                         amount: item.amount,
//                         onEdit: () => _openDiscountDialog(index: index, discount: item),
//                         onDelete: () => _confirmDelete(index),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DiscountCard extends StatelessWidget {
//   const DiscountCard({
//     super.key,
//     required this.isTablet,
//     required this.code,
//     required this.name,
//     required this.amount,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   final bool isTablet;
//   final String code;
//   final String name;
//   final String amount;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   @override
//   Widget build(BuildContext context) {
//     final double pad = isTablet ? 16 : 12;
//     final double radius = isTablet ? 14 : 12;
//     final double titleSize = isTablet ? 18 : 16;
//     final double subtitleSize = isTablet ? 16 : 14;
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: pad, vertical: pad / 2),
//       padding: EdgeInsets.all(pad),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(radius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: isTablet ? 26 : 22,
//             backgroundColor: Colors.blue.shade50,
//             child: Text(
//               code.isNotEmpty ? code[0].toUpperCase() : 'V',
//               style: TextStyle(
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w700,
//                 fontSize: isTablet ? 18 : 16,
//               ),
//             ),
//           ),
//           SizedBox(width: pad),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Flexible(
//                       child: Text(
//                         'Mã: $code',
//                         style: TextStyle(fontSize: subtitleSize, color: Colors.grey[700]),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Flexible(
//                       child: Text(
//                         'Giảm: $amount',
//                         style: TextStyle(fontSize: subtitleSize, color: Colors.grey[700]),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, size: isTablet ? 26 : 22, color: Colors.black54),
//             onSelected: (value) {
//               if (value == 'edit') {
//                 onEdit();
//               } else if (value == 'delete') {
//                 onDelete();
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'edit',
//                 child: Row(
//                   children: const [
//                     Icon(Icons.edit, size: 18),
//                     SizedBox(width: 8),
//                     Text('Sửa'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'delete',
//                 child: Row(
//                   children: const [
//                     Icon(Icons.delete, size: 18),
//                     SizedBox(width: 8),
//                     Text('Xóa'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
