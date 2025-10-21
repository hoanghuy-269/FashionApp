// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'admin_discount_screen.dart';
// import 'admin_manageshop_screen.dart';
// import 'admin_shopAccount_screeen.dart';
// import 'admin_confirm_screen.dart';

// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({super.key});
//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }

// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   bool showRevenue = true;
//   bool showOrders = true;

//   // Ví dụ số liệu
//   int revenue = 24042005;
//   int orders = 342;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600 && size.width <= 1024;
//     final isDesktop = size.width > 1024;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F5F7),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(
//             isDesktop
//                 ? 48
//                 : isTablet
//                 ? 24
//                 : 16,
//           ),
//           child: Column(
//             children: [
//               // --- Header ---
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal:
//                       isDesktop
//                           ? 48
//                           : isTablet
//                           ? 24
//                           : 16,
//                   vertical:
//                       isDesktop
//                           ? 24
//                           : isTablet
//                           ? 16
//                           : 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue.shade100, Colors.white],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: isTablet ? 30 : 24,
//                       backgroundColor: const Color.fromARGB(255, 41, 127, 129),
//                       child: Icon(
//                         Icons.person,
//                         color: Colors.white,
//                         size: isTablet ? 34 : 28,
//                       ),
//                     ),
//                     SizedBox(width: isTablet ? 16 : 12),
//                     Expanded(
//                       child: Text(
//                         'Admin',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: isTablet ? 20 : 18,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.notifications_none,
//                         size: isTablet ? 30 : 26,
//                       ),
//                       color: Colors.blueGrey[700],
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AdminConfirmScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(
//                 height:
//                     isDesktop
//                         ? 32
//                         : isTablet
//                         ? 24
//                         : 20,
//               ),

//               // --- 2 nút thống kê có ẩn/hiện số riêng ---
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildStatButton(
//                       'Doanh thu',
//                       showRevenue ? revenue.toString() : '******',
//                       isTablet,
//                       () {
//                         setState(() {
//                           showRevenue = !showRevenue;
//                         });
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width:
//                         isDesktop
//                             ? 32
//                             : isTablet
//                             ? 20
//                             : 16,
//                   ),
//                   Expanded(
//                     child: _buildStatButton(
//                       'Số đơn',
//                       showOrders ? orders.toString() : '***',
//                       isTablet,
//                       () {
//                         setState(() {
//                           showOrders = !showOrders;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(
//                 height:
//                     isDesktop
//                         ? 32
//                         : isTablet
//                         ? 24
//                         : 20,
//               ),

//               // --- 3 ô chính, mỗi ô một dòng ---
//               Expanded(
//                 child:
//                     isDesktop
//                         ? GridView.count(
//                           crossAxisCount: 2,
//                           childAspectRatio: 2.5,
//                           crossAxisSpacing: 24,
//                           mainAxisSpacing: 24,
//                           children: [
//                             _buildGridItemFullWidth(
//                               Icons.people_alt_rounded,
//                               'Khách hàng',
//                               Colors.teal,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminShopaccountScreeen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridItemFullWidth(
//                               Icons.manage_accounts_rounded,
//                               'Quản lý shop',
//                               Colors.deepPurple,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminManageshopScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridItemFullWidth(
//                               Icons.local_offer_rounded,
//                               'Mã giảm giá',
//                               Colors.pinkAccent,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminDiscountScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         )
//                         : ListView(
//                           children: [
//                             _buildGridItemFullWidth(
//                               Icons.people_alt_rounded,
//                               'Khách hàng',
//                               Colors.teal,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminShopaccountScreeen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             SizedBox(height: isTablet ? 16 : 12),
//                             _buildGridItemFullWidth(
//                               Icons.manage_accounts_rounded,
//                               'Quản lý shop',
//                               Colors.deepPurple,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminManageshopScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             SizedBox(height: isTablet ? 16 : 12),
//                             _buildGridItemFullWidth(
//                               Icons.local_offer_rounded,
//                               'Mã giảm giá',
//                               Colors.pinkAccent,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                             const AdminDiscountScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatButton(
//     String title,
//     String value,
//     bool isTablet,
//     VoidCallback toggle,
//   ) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: isTablet ? 16 : 14,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: isTablet ? 20 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 8),
//           InkWell(
//             onTap: toggle,
//             child: Icon(
//               value.contains('*') ? Icons.visibility_off : Icons.visibility,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridItemFullWidth(
//     IconData icon,
//     String title,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: onTap,
//       child: Container(
//         height: 120,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: color.withOpacity(0.15),
//               child: Icon(icon, color: color, size: 32),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
