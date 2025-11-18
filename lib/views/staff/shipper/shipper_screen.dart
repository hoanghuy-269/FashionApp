import 'package:flutter/material.dart';

class ShipperScreen extends StatefulWidget {
  const ShipperScreen({super.key});

  @override
  State<ShipperScreen> createState() => _ShipperScreenState();
}

class _ShipperScreenState extends State<ShipperScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          'assets/images/logo_person.png',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Xin chào, Shipper!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
