import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

extension FlushbarExtension on BuildContext {
  /// Hàm lõi hiển thị Flushbar tùy chỉnh
  void showFlushMessage({
    required String message,
    Color backgroundColor = Colors.blue,
    IconData icon = Icons.info,
    int durationSeconds = 2,
  }) {
    Flushbar(
      message: message,
      duration: Duration(seconds: durationSeconds),
      icon: Icon(
        icon,
        size: 28.0,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: backgroundColor,
    ).show(this);
  }

  /// Thông báo lỗi
  void showError(String message) {
    showFlushMessage(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// Thông báo thành công
  void showSuccess(String message) {
    showFlushMessage(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Thông báo cảnh báo
  void showWarning(String message) {
    showFlushMessage(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
    );
  }
}
