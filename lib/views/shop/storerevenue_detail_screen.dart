import 'package:flutter/material.dart';

class StorerevenueDetailScreen extends StatefulWidget {
  const StorerevenueDetailScreen({super.key});

  @override
  State<StorerevenueDetailScreen> createState() => _StorerevenueDetailScreenState();
}

class _StorerevenueDetailScreenState extends State<StorerevenueDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Chi tiết doanh thu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          
            const SizedBox(height: 20),
            const Text(
              "Đơn hàng",
              style: TextStyle(fontSize: 20),
            ),
            const Text(
              " Số đơn hàng dã giao thành công : "
            ),
          ],
        ),
      ),
    );
  }
}