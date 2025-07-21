import 'package:flutter/material.dart';
import '../../ar_view/presentation/ar_view_screen.dart';
import 'sign_up_screen.dart';
import 'dart:math';
import '../../home/presentation/main_screen.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late AnimationController _particleController;
  static final Map<String, String> _userStore = {'user': '123456'};
  bool _showSignUp = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _showSignUpScreen() {
    setState(() {
      _showSignUp = true;
    });
  }
  void _backToLogin() {
    setState(() {
      _showSignUp = false;
    });
  }
  void _registerUser(String username, String password) {
    if (_userStore.containsKey(username)) {
      setState(() {
        _error = 'Tài khoản đã tồn tại!';
        _isLoading = false;
        _showSignUp = false;
      });
      return;
    }
    _userStore[username] = password;
    setState(() {
      _error = 'Đăng ký thành công!';
      _isLoading = false;
      _showSignUp = false;
    });
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _authService.login(_usernameController.text, _passwordController.text);
      if (result['token'] != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        setState(() {
          _error = result['message'] ?? 'Đăng nhập thất bại';
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
    if (_showSignUp) {
      return SignUpScreen(
        onSignUp: _registerUser,
        onBackToLogin: _backToLogin,
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Stack(
        children: [
          Positioned.fill(
            child: ParticleBackground(animation: _particleController),
          ),
          Center(
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
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'KING AR EXPERIENCE',
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
                                          _login();
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
                                    : const Text('Login', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _showSignUpScreen,
                              child: const Text('Chưa có tài khoản? Đăng ký', style: TextStyle(color: Colors.white70)),
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
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ARViewScreen();
  }
}

class ParticleBackground extends StatelessWidget {
  final Animation<double> animation;
  const ParticleBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(animation.value),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount = 60;
  final Random random = Random(42);
  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withOpacity(0.18);
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 9999;
      final angle = (progress * 2 * pi + i * pi / 7 + seed) % (2 * pi);
      final radius = (size.shortestSide / 2.2) * (0.4 + 0.5 * (sin(progress * 2 * pi + i) + 1) / 2);
      final dx = size.width / 2 + radius * cos(angle + i);
      final dy = size.height / 2 + radius * sin(angle - i / 2);
      final r = 1.5 + 2.5 * (sin(progress * 2 * pi + i * 1.3) + 1) / 2;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
} 