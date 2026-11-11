import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // CREATE - Thêm user
  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    String image = '',
  }) async {
    await users.add({
      'username': username,
      'email': email,
      'password': password,
      'image': image,
    });
  }

  // READ - Lấy danh sách user realtime
  Stream<QuerySnapshot> getUsers() {
    return users.snapshots();
  }

  // UPDATE - Sửa user
  Future<void> updateUser({
    required String id,
    required String username,
    required String email,
    required String password,
    required String image,
  }) async {
    await users.doc(id).update({
      'username': username,
      'email': email,
      'password': password,
      'image': image,
    });
  }

  // DELETE - Xóa user
  Future<void> deleteUser(String id) async {
    await users.doc(id).delete();
  }
}