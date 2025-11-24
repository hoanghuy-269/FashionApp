import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StaffSearchBar extends StatelessWidget {
  const StaffSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorestaffViewmodel>(
      builder: (context, vm, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            enabled: !vm.isLoading,
            onChanged: (value) {
              if (!vm.isLoading && vm.staffs.isNotEmpty) {
                vm.searchStaff(value);
              }
            },
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                LucideIcons.search,
                color: vm.isLoading ? Colors.grey.shade400 : Colors.blue.shade600,
                size: 22,
              ),
              suffixIcon: vm.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    )
                  : null,
              hintText: vm.isLoading 
                  ? "Đang tải dữ liệu..." 
                  : "Tìm kiếm theo tên nhân viên...",
              hintStyle: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.blue.shade600,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}