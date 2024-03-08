import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';

class UploadPdfScreen extends StatefulWidget {
  final FilePickerResult? pickedFile;
  final String name;
  final String path;

  const UploadPdfScreen({
    super.key,
    required this.pickedFile,
    required this.name,
    required this.path,
  });

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  bool loading = false;
  double perCent = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 10,
                    percent: perCent / 100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.green,
                    center: Text('${perCent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                : _pdfIsPicked(),
          ],
        ),
      ),
    );
  }

  Widget _pdfIsPicked() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Do you want to upload ?',
          style: TextStyle(fontSize: 25),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/pdf.png', width: mq.width * .45),
        ),
        Text(widget.name),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Yes'),
                onPressed: () async {
                  await APIs.pickFile(context, widget.pickedFile,
                      uploadPdf(context, widget.name, File(widget.path)));
                },
              ),
              ElevatedButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // for uploading pdfs
  Future<String> uploadPdf(
      BuildContext context, String fileName, File file) async {
    setState(() {
      loading = true;
    });
    String downloadLink = '';

    // storage file reference with path
    final ref = APIs.storage.ref().child('PDFs/$fileName');

    // for uploading file
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((event) async {
      switch (event.state) {
        case TaskState.running:
          final progress = 100 * (event.bytesTransferred / event.totalBytes);
          setState(() {
            perCent = progress.toDouble();
          });
          log('Upload is $progress% completed!');
          break;
        case TaskState.paused:
          log('Upload is paused!');
          break;
        case TaskState.canceled:
          log('Upload is cancelled!');
          break;
        case TaskState.error:
          log('Error while uploading!');
          break;
        case TaskState.success:
          setState(() {
            loading = false;
          });
          Dialogs.showSnackBar(context, 'PDF uploaded successfully!');
          Navigator.pop(context);
          downloadLink = await ref.getDownloadURL();
          log('Pdf uploaded successfully!');
          break;
      }
    });

    // for uploading pdfs
    // await ref.putFile(file).whenComplete(() {
    //   Dialogs.showSnackBar(context, 'PDF uploaded successfully!');
    // });

    // for generating download link
    // final downloadLink = await ref.getDownloadURL();
    return downloadLink;
  }
}
