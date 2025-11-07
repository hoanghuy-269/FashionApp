import 'package:fashion_app/views/shop/add_importgoods/add_importgoods_screen.dart';
import 'package:flutter/material.dart';

class ImportgoodsCreen extends StatefulWidget {
  const ImportgoodsCreen({super.key});

  @override
  State<ImportgoodsCreen> createState() => _ImportgoodsCreenState();
}

class _ImportgoodsCreenState extends State<ImportgoodsCreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                    ),
                    Spacer(),
                    Text(
                      "Nhập hàng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AddImportgoodsScreen(),
                        ));
                      },
                      icon: Icon(Icons.add, size: 30, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Tab barr
              const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [Tab(text: "Yêu cầu nhập "), Tab(text: "Đang nhập ")],
              ),

              // Tab Yêu cầu nhập
              Expanded(child: TabBarView(children: [
                // tab 1 
                Center(child: Text("Yêu cầu nhập hàng")),
                // tab 2
                Center(child: Text("Đang nhập hàng")),
              ])),
            ],
          ),
        ),
      ),
    );
  }
  
}
