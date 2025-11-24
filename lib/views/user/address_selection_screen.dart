import 'package:fashion_app/data/models/address.dart';
import 'package:fashion_app/views/user/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String userId;
  const AddressSelectionScreen({required this.userId});

  @override
  _AddressSelectionScreenState createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<Address> addresses = [];
  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("addresses")
              .get();

      List<Address> loadedAddresses = [];

      for (var doc in snapshot.docs) {
        try {
          final address = Address.fromFirestore(doc.data(), doc.id);
          loadedAddresses.add(address);
        } catch (e) {
          print('Lỗi parse địa chỉ: $e');
        }
      }

      setState(() {
        addresses = loadedAddresses;

        if (addresses.isNotEmpty) {
          // Chọn địa chỉ mặc định hoặc địa chỉ đầu tiên
          selectedAddress = addresses.firstWhere(
            (address) => address.isDefault == true,
            orElse: () => addresses.first,
          );
        } else {
          selectedAddress = null;
        }
      });
    } catch (e) {
      print('Lỗi load addresses: $e');
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("addresses")
          .doc(addressId)
          .delete();

      await _loadAddresses(); // Reload danh sách
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  void _selectAddress(Address address) {
    Navigator.pop(context, address);
  }

  void _onAddressSelected(Address address) {
    setState(() {
      selectedAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn địa chỉ nhận hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Địa chỉ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Danh sách địa chỉ
          Expanded(
            child:
                addresses.isEmpty
                    ? _buildEmptyAddress()
                    : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return _buildAddressItem(address);
                      },
                    ),
          ),

          // Nút thêm địa chỉ mới
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final newAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddressScreen(userId: widget.userId),
                    ),
                  );
                  if (newAddress != null) {
                    await _loadAddresses();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.red.shade400),
                ),
                icon: Icon(Icons.add, color: Colors.red.shade400),
                label: Text(
                  'Thêm Địa Chỉ Mới',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm địa chỉ để bắt đầu mua sắm',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(Address address) {
    return Dismissible(
      key: Key(address.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(address);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selectedAddress?.id == address.id
                    ? Colors.red.shade300
                    : Colors.grey.shade200,
            width: selectedAddress?.id == address.id ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectAddress(address),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Radio<Address>(
                      value: address,
                      groupValue: selectedAddress,
                      onChanged: (Address? value) {
                        if (value != null) {
                          _onAddressSelected(value);
                        }
                      },
                      activeColor: Colors.red,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  // Thông tin địa chỉ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên và số điện thoại
                        Row(
                          children: [
                            Text(
                              address.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Địa chỉ chi tiết
                        Text(
                          address.detail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Phường, Quận, Tỉnh
                        Text(
                          '${address.ward}, ${address.district}, ${address.province}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(Address address) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa địa chỉ'),
            content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('HỦY'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('XÓA', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteAddress(address.id);
      return true;
    }
    return false;
  }
}
