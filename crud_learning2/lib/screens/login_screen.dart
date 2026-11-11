import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool hidePassword = true;
  String? errorMessage;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng nhập email và mật khẩu';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await authService.login(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;

        if (e.code == 'invalid-credential' ||
            e.code == 'wrong-password' ||
            e.code == 'user-not-found') {
          errorMessage = 'Email hoặc mật khẩu không đúng';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ';
        } else {
          errorMessage = 'Đăng nhập thất bại';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Có lỗi xảy ra';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer,
              const Color(0xFFF6F7FB),
              Colors.white,
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 440,
                ),

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius:
                            BorderRadius.circular(22),
                          ),

                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 42,
                            color: colors.primary,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Đăng nhập để quản lý người dùng',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: emailController,
                          keyboardType:
                          TextInputType.emailAddress,

                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'admin@gmail.com',
                            prefixIcon:
                            Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,

                          onSubmitted: (_) {
                            if (!isLoading) {
                              login();
                            }
                          },

                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                            const Icon(Icons.lock_outline),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePassword =
                                  !hidePassword;
                                });
                              },

                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons
                                    .visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 14),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colors.error,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: colors
                                          .onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,

                          child: FilledButton.icon(
                            onPressed:
                            isLoading ? null : login,

                            icon: isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,

                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                              Icons.login_rounded,
                            ),

                            label: Text(
                              isLoading
                                  ? 'Đang đăng nhập...'
                                  : 'Đăng nhập',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}