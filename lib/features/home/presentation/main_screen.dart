import 'package:flutter/material.dart';
import '../../ar_view/presentation/ar_view_screen.dart';
import '../../../main.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../auth/presentation/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeTab(),
          ModelsTab(),
          SettingsTab(),
          PaymentTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chính'),
          BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'Mô hình'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Thanh toán'),
        ],
      ),
    );
  }
}

// class HomeTab extends StatelessWidget {
//   const HomeTab({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Trang chính', style: TextStyle(fontSize: 22)),
//     );
//   }
// }
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea( // ✅ Thêm dòng này để tránh bị dính camera/tai thỏ
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.precision_manufacturing_rounded, size: 72, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'Chào mừng đến với AR Lắp Ráp!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Trải nghiệm hướng dẫn lắp ráp sản phẩm bằng công nghệ thực tế tăng cường (AR).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () => _switchTab(context, 1),
              icon: const Icon(Icons.view_in_ar),
              label: const Text('Bắt đầu lắp ráp mô hình'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () => _switchTab(context, 2),
              icon: const Icon(Icons.settings),
              label: const Text('Cài đặt ứng dụng'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () => _switchTab(context, 3),
              icon: const Icon(Icons.payment),
              label: const Text('Nâng cấp / Mua thêm'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 32),

            const Text(
              'Phiên bản: 1.0.0\n© 2025 AR Assembly App',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?.setState(() {
      state._currentIndex = index;
    });
  }
}



class ModelsTab extends StatelessWidget {
  const ModelsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.view_in_ar),
        label: const Text('Chọn mô hình & mở AR'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ARViewScreen()),
          );
        },
      ),
    );
  }
}

// class SettingsTab extends StatelessWidget {
//   const SettingsTab({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text('Cài đặt', style: TextStyle(fontSize: 22)),
//           const SizedBox(height: 32),
//           ValueListenableBuilder<ThemeMode>(
//             valueListenable: themeModeNotifier,
//             builder: (context, mode, _) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.light_mode),
//                   Switch(
//                     value: mode == ThemeMode.dark,
//                     onChanged: (val) {
//                       themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
//                     },
//                   ),
//                   const Icon(Icons.dark_mode),
//                   const SizedBox(width: 12),
//                   Text(mode == ThemeMode.dark ? 'Chế độ tối' : 'Chế độ sáng'),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// 
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AccountDialog(),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SupportDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Cài đặt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            icon: const Icon(Icons.account_circle),
            label: const Text('Thông tin tài khoản'),
            onPressed: () => _showAccountDialog(context),
          ),
          const SizedBox(height: 16),

          const Text('Giao diện & Chủ đề', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) {
              return Row(
                children: [
                  const Icon(Icons.light_mode),
                  Switch(
                    value: mode == ThemeMode.dark,
                    onChanged: (val) {
                      themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 12),
                  Text(mode == ThemeMode.dark ? 'Chế độ tối' : 'Chế độ sáng'),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Text('Ngôn ngữ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: 'vi',
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              // Xử lý chuyển ngôn ngữ ở đây
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đổi ngôn ngữ chưa được hỗ trợ.')),
              );
            },
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.support_agent),
            label: const Text('Hỗ trợ & Phản hồi'),
            onPressed: () => _showSupportDialog(context),
          ),
        ],
      ),
    );
  }
}


class AccountDialog extends StatefulWidget {
  const AccountDialog({super.key});
  @override
  State<AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  File? _avatar;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatar = File(picked.path);
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pop(); // Đóng dialog
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tài khoản của bạn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
              child: _avatar == null ? const Icon(Icons.person, size: 40) : null,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Tên người dùng', style: TextStyle(fontSize: 18)),
          // Có thể thêm thông tin email, v.v.
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _logout(context),
          child: const Text('Đăng xuất'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hỗ trợ & Phản hồi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Gửi phản hồi'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng phản hồi chưa được kích hoạt.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Chính sách & Điều khoản'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Chính sách & Điều khoản'),
                  content: Text('Ứng dụng AR Lắp Ráp cam kết bảo mật thông tin người dùng...'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Liên hệ hỗ trợ'),
            subtitle: const Text('support@arapp.vn'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
      ],
    );
  }
}



class PaymentTab extends StatelessWidget {
  const PaymentTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Thanh toán', style: TextStyle(fontSize: 22)),
    );
  }
} 
