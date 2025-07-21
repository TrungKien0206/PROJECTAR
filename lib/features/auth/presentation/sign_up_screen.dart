import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final void Function(String username, String password) onSignUp;
  final VoidCallback onBackToLogin;
  const SignUpScreen({super.key, required this.onSignUp, required this.onBackToLogin});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  void _signUp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Mật khẩu xác nhận không khớp!';
        _isLoading = false;
      });
      return;
    }
    try {
      final result = await _authService.register(_usernameController.text, _passwordController.text);
      if (result['message'] == 'Đăng ký thành công') {
        widget.onSignUp(_usernameController.text, _passwordController.text);
      } else {
        setState(() {
          _error = result['message'] ?? 'Đăng ký thất bại';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối hoặc server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 3),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ĐĂNG KÝ TÀI KHOẢN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.blueAccent,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                color: Colors.black.withOpacity(0.7),
                elevation: 12,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Nhập tài khoản' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Nhập mật khẩu' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Nhập lại mật khẩu' : null,
                        ),
                        const SizedBox(height: 28),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_error!, style: const TextStyle(color: Colors.red)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _signUp();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 6,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Đăng ký', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: widget.onBackToLogin,
                          child: const Text('Quay lại đăng nhập', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 