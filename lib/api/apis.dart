import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class APIs {
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for uploading pdfs
  static Future<String> uploadPdf(String fileName, File file) async {
    // storage file reference with path
    final ref = storage.ref().child('PDFs/$fileName.pdf');

    // for uploading pdfs
    await ref.putFile(file).whenComplete(() {});

    // for generating download link
    final downloadLink = await ref.getDownloadURL();
    return downloadLink;
  }

  // for picking files
  static Future<void> pickFile(FilePickerResult? pickedFile) async {
    // final pickedFile = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    //   allowCompression: true,
    // );

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);
      final downloadLink = await uploadPdf(fileName, file);

      // for adding
      await firestore.collection('PDFs').add({
        'name': fileName,
        'url': downloadLink,
      });
    }
  }
}
