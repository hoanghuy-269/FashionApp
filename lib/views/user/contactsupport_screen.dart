import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Gửi email
  Future<void> _sendEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'xinmax681@gmail.com',
      query: 'subject=Hỗ trợ từ người dùng&body=${_messageController.text}',
    );
    await launchUrl(uri);
  }

  // Gọi hotline
  Future<void> _callHotline() async {
    final Uri uri = Uri(scheme: 'tel', path: "0971145573");
    await launchUrl(uri);
  }

  // Gửi tin nhắn in-app (tuỳ bạn xử lý Firestore)
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung cần hỗ trợ')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tin nhắn đã được gửi!')),
    );

    _messageController.clear();
  }

  // Mở Zalo
  Future<void> _openZalo() async {
    const zaloUrl = 'https://zalo.me/0971145573'; // đổi số của bạn
    final Uri url = Uri.parse(zaloUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // Mở Messenger
  Future<void> _openMessenger() async {
    const messengerUrl = 'https://m.me/tungdz.tungdz.9'; // đổi page ID của bạn
    final Uri url = Uri.parse(messengerUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liên hệ hỗ trợ"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chúng tôi luôn sẵn sàng hỗ trợ bạn!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildSupportCard(
              icon: Icons.email,
              title: "Gửi email hỗ trợ",
              subtitle: "người hỗ trợ của bạn : Hoàng Huy Fashion",
              onTap: _sendEmail,
            ),
            const SizedBox(height: 12),

            _buildSupportCard(
              icon: Icons.phone,
              title: "Hotline hỗ trợ",
              subtitle: "người hỗ trợ của bạn : Tùng fashion",
              onTap: _callHotline,
            ),
            const SizedBox(height: 12),

            _buildSupportCard(
              icon: Icons.chat_bubble,
              title: "Chat qua Zalo",
              subtitle: "người hỗ trợ của bạn : Tùng fashion",
              onTap: _openZalo,
            ),
            const SizedBox(height: 12),

            _buildSupportCard(
              icon: Icons.facebook,
              title: "Chat qua Messenger",
              subtitle: "người hỗ trợ của bạn : Tùng fashion",
              onTap: _openMessenger,
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
