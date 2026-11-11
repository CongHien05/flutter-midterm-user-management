import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserFormDialog extends StatefulWidget {
  final String? username;
  final String? email;
  final String? password;
  final String? image;

  const UserFormDialog({
    super.key,
    this.username,
    this.email,
    this.password,
    this.image,
  });

  bool get isEdit => username != null;

  @override
  State<UserFormDialog> createState() =>
      _UserFormDialogState();
}

class _UserFormDialogState
    extends State<UserFormDialog> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  Uint8List? selectedImageBytes;

  String imageBase64 = '';
  String? errorMessage;

  bool hidePassword = true;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(
      text: widget.username ?? '',
    );

    emailController = TextEditingController(
      text: widget.email ?? '',
    );

    passwordController = TextEditingController(
      text: widget.password ?? '',
    );

    imageBase64 = widget.image ?? '';

    if (imageBase64.isNotEmpty) {
      try {
        selectedImageBytes =
            base64Decode(imageBase64);
      } catch (_) {
        selectedImageBytes = null;
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 25,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImageBytes = bytes;
      imageBase64 = base64Encode(bytes);
    });
  }

  void submit() {
    final username =
    usernameController.text.trim();

    final email =
    emailController.text.trim();

    final password =
    passwordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() {
        errorMessage =
        'Vui lòng nhập đầy đủ thông tin';
      });

      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Email không hợp lệ';
      });

      return;
    }

    Navigator.pop(
      context,
      {
        'username': username,
        'email': email,
        'password': password,
        'image': imageBase64,
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        0,
      ),

      contentPadding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        0,
      ),

      actionsPadding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24,
      ),

      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              widget.isEdit
                  ? Icons.edit_rounded
                  : Icons.person_add_alt_1_rounded,
              color: colors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              widget.isEdit
                  ? 'Sửa người dùng'
                  : 'Thêm người dùng',
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: 420,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              GestureDetector(
                onTap: pickImage,

                child: Stack(
                  alignment: Alignment.bottomRight,

                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                      colors.primaryContainer,

                      backgroundImage:
                      selectedImageBytes != null
                          ? MemoryImage(
                        selectedImageBytes!,
                      )
                          : null,

                      child: selectedImageBytes == null
                          ? Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: colors.primary,
                      )
                          : null,
                    ),

                    Container(
                      padding: const EdgeInsets.all(7),

                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),

                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text(
                  'Chọn ảnh đại diện',
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: usernameController,

                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon:
                  Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: emailController,
                keyboardType:
                TextInputType.emailAddress,

                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                  Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,

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
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),

                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color:
                      colors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text('Hủy'),
        ),

        FilledButton.icon(
          onPressed: submit,

          icon: Icon(
            widget.isEdit
                ? Icons.save_outlined
                : Icons.add_rounded,
          ),

          label: Text(
            widget.isEdit
                ? 'Lưu thay đổi'
                : 'Thêm người dùng',
          ),
        ),
      ],
    );
  }
}