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
    if (value == null) return null;

    final image = value.toString();

    if (image.isEmpty) return null;

    try {
      return base64Decode(image);
    } catch (_) {
      return null;
    }
  }

  Future<void> addUser(
      BuildContext context,
      UserService userService,
      ) async {
    final result =
    await showDialog<Map<String, dynamic>>(
      context: context,

      builder: (context) {
        return const UserFormDialog();
      },
    );

    if (result == null) return;

    try {
      await userService.addUser(
        username: result['username'],
        email: result['email'],
        password: result['password'],
        image: result['image'],
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thêm người dùng thành công',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể thêm người dùng',
          ),
        ),
      );
    }
  }

  Future<void> editUser(
      BuildContext context,
      UserService userService,
      String id,
      Map<String, dynamic> data,
      ) async {
    final result =
    await showDialog<Map<String, dynamic>>(
      context: context,

      builder: (context) {
        return UserFormDialog(
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          image: data['image'] ?? '',
        );
      },
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

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cập nhật người dùng thành công',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể cập nhật người dùng',
          ),
        ),
      );
    }
  }

  Future<void> deleteUser(
      BuildContext context,
      UserService userService,
      String id,
      String username,
      ) async {
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 40,
            color: colors.error,
          ),

          title: const Text(
            'Xóa người dùng?',
            textAlign: TextAlign.center,
          ),

          content: Text(
            'Bạn có chắc muốn xóa "$username"? '
                'Hành động này không thể hoàn tác.',
            textAlign: TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Hủy'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await userService.deleteUser(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã xóa người dùng',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể xóa người dùng',
          ),
        ),
      );
    }
  }

  Future<void> logout(
      BuildContext context,
      AuthService authService,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text(
            'Bạn có muốn đăng xuất khỏi hệ thống?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Hủy'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
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
        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'User Management',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Quản lý người dùng',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding:
            const EdgeInsets.only(right: 8),

            child: IconButton(
              tooltip: 'Đăng xuất',

              onPressed: () {
                logout(
                  context,
                  authService,
                );
              },

              icon: const Icon(
                Icons.logout_rounded,
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: userService.getUsers(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  CircularProgressIndicator(),

                  SizedBox(height: 14),

                  Text(
                    'Đang tải người dùng...',
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 70,
                      color: colors.error,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Không thể tải dữ liệu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 52,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Chưa có người dùng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Nhấn nút + để thêm người dùng đầu tiên',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  8,
                ),

                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        child: Icon(
                          Icons.groups_rounded,
                          color: colors.onPrimary,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Tổng người dùng',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),

                          Text(
                            '${users.length}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    100,
                  ),

                  itemCount: users.length,

                  separatorBuilder:
                      (context, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },

                  itemBuilder:
                      (context, index) {
                    final document =
                    users[index];

                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final imageBytes =
                    decodeImage(
                      data['image'],
                    );

                    final username =
                        data['username']
                            ?.toString() ??
                            '';

                    final email =
                        data['email']
                            ?.toString() ??
                            '';

                    return Card(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(14),

                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 29,

                              backgroundColor:
                              colors
                                  .primaryContainer,

                              backgroundImage:
                              imageBytes != null
                                  ? MemoryImage(
                                imageBytes,
                              )
                                  : null,

                              child:
                              imageBytes == null
                                  ? Icon(
                                Icons
                                    .person_rounded,
                                color: colors
                                    .primary,
                              )
                                  : null,
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  Text(
                                    username,

                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,

                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .email_outlined,
                                        size: 16,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Expanded(
                                        child: Text(
                                          email,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,

                                          style:
                                          TextStyle(
                                            color: Colors
                                                .grey
                                                .shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .lock_outline,
                                        size: 16,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Text(
                                        'Password: ••••••',
                                        style:
                                        TextStyle(
                                          color: Colors
                                              .grey
                                              .shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              tooltip: 'Sửa',

                              onPressed: () {
                                editUser(
                                  context,
                                  userService,
                                  document.id,
                                  data,
                                );
                              },

                              icon: Icon(
                                Icons.edit_outlined,
                                color:
                                colors.primary,
                              ),
                            ),

                            IconButton(
                              tooltip: 'Xóa',

                              onPressed: () {
                                deleteUser(
                                  context,
                                  userService,
                                  document.id,
                                  username,
                                );
                              },

                              icon: Icon(
                                Icons
                                    .delete_outline,
                                color: colors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          addUser(
            context,
            userService,
          );
        },

        icon: const Icon(
          Icons.person_add_alt_1_rounded,
        ),

        label: const Text(
          'Thêm user',
        ),
      ),
    );
  }
}