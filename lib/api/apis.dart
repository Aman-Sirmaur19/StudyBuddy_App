import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/main_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  /// ******** User related API *********

  // for storing self info
  static late MainUser me;

  static User get user => auth.currentUser!;

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for finding a user name by its user id
  static Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        String userName = userSnapshot['name'] ?? 'Unknown';
        return userName;
      } else {
        log('User not found');
      }
    } catch (e) {
      log('Error getting user info: $e');
    }
    return null;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = MainUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final mainUser = MainUser(
      id: user.uid,
      name: 'Unknown',
      branch: '',
      college: '',
      email: '',
      about: 'Hey, I am using StudyBuddy!',
      image: '',
      createdAt: time,
      uploads: 0,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(mainUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').snapshots();
  }

  // for updating user info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
      'branch': me.branch,
      'college': me.college,
      'email': me.email,
    });
  }

  static Future<void> updateUploads(int n) async {
    await getSelfInfo();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'uploads': me.uploads + n});
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    // storage file reference with path
    final ref = storage.ref('profile_picture/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1024} kb');
    });

    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }
}
