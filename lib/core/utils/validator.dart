class Validator {
  ///Kiểm tra định dạng email
  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(trimmed);
  }

  //Kiểm tra mật khẩu
  static bool isValidPassword(String password) {
    final trimmed = password.trim();
    final passwordRegex = RegExp(
      r'^[A-Z](?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{5,}$',
    );
    return passwordRegex.hasMatch(trimmed);
  }

  // Kiểm tra sdt
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }

  

}
