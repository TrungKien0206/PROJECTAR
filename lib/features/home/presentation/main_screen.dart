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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Trang chính', style: TextStyle(fontSize: 22)),
    );
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

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Cài đặt', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.account_circle),
            label: const Text('Xem tài khoản'),
            onPressed: () => _showAccountDialog(context),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
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


class PaymentTab extends StatelessWidget {
  const PaymentTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Thanh toán', style: TextStyle(fontSize: 22)),
    );
  }
} 