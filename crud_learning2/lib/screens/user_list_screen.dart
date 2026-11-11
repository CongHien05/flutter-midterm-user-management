import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/user_form_dialog.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  Uint8List? decodeImage(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    try {
      return base64Decode(value.toString());
    } catch (_) {
      return null;
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> addUser(
    BuildContext context,
    UserService userService,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const UserFormDialog(),
    );

    if (result == null) return;

    try {
      await userService.addUser(
        username: result['username'],
        email: result['email'],
        password: result['password'],
        image: result['image'],
      );

      if (context.mounted) {
        showMessage(context, 'Thêm người dùng thành công');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Không thể thêm người dùng');
      }
    }
  }

  Future<void> editUser(
    BuildContext context,
    UserService userService,
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserFormDialog(
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        password: data['password'] ?? '',
        image: data['image'] ?? '',
      ),
    );

    if (result == null) return;

    try {
      await userService.updateUser(
        id: id,
        username: result['username'],
        email: result['email'],
        password: result['password'],
        image: result['image'],
      );

      if (context.mounted) {
        showMessage(context, 'Cập nhật thành công');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Không thể cập nhật');
      }
    }
  }

  Future<void> deleteUser(
    BuildContext context,
    UserService userService,
    String id,
    String username,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có chắc muốn xóa "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await userService.deleteUser(id);

      if (context.mounted) {
        showMessage(context, 'Đã xóa người dùng');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Không thể xóa người dùng');
      }
    }
  }

  Future<void> logout(
    BuildContext context,
    AuthService authService,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authService.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final authService = AuthService();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => logout(context, authService),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Không thể tải dữ liệu'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Chưa có người dùng. Nhấn + để thêm.'),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = users[index];
              final data = document.data() as Map<String, dynamic>;

              final username = data['username']?.toString() ?? '';
              final email = data['email']?.toString() ?? '';
              final imageBytes = decodeImage(data['image']);

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage:
                        imageBytes != null ? MemoryImage(imageBytes) : null,
                    child: imageBytes == null
                        ? Icon(Icons.person_rounded, color: colors.primary)
                        : null,
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$email\nPassword: ••••••'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Sửa',
                        onPressed: () => editUser(
                          context,
                          userService,
                          document.id,
                          data,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Xóa',
                        onPressed: () => deleteUser(
                          context,
                          userService,
                          document.id,
                          username,
                        ),
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addUser(context, userService),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Thêm'),
      ),
    );
  }
}
