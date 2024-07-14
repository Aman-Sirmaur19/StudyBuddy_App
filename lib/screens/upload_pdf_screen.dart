import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/pdf_model.dart';
import '../helper/get_file_size.dart';
import '../widgets/category_item.dart';
import '../widgets/particle_animation.dart';

class UploadPdfScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String path;

  const UploadPdfScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.path,
  });

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;

  bool loading = false;
  double perCent = 0;

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  String? selectedCategory;

  List<String> categories = [];

  initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8331104249',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  void addCategoriesFromDummyData() {
    categories.clear();
    for (final category in DUMMY_CATEGORIES) {
      categories.add(category.title);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    categoryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    addCategoriesFromDummyData();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            particles(context),
            Padding(
              padding: EdgeInsets.only(top: mq.width * .2),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    loading
                        ? Center(
                      child: CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 10,
                        percent: perCent / 100,
                        backgroundColor: Colors.grey,
                        progressColor: Colors.green,
                        center: Text('${perCent.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                        : _pdfIsPicked(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // custom textField
  Widget textField({
    required String labelText,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .03, vertical: mq.width * .05),
      child: TextFormField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color:
                  Theme.of(context).colorScheme.secondary.withOpacity(.4))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary)),
          labelText: labelText,
          border: InputBorder.none,
          filled: true,
        ),
      ),
    );
  }

  Widget _pdfIsPicked() {
    double pdfSize = getFileSize(widget.path);
    log('size: $pdfSize');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: mq.width * .02),
          child: Image.asset('assets/images/pdf.png', width: mq.width * .35),
        ),
        Text(widget.name, textAlign: TextAlign.center),
        textField(
          labelText: 'PDF Name',
          inputType: TextInputType.text,
          maxLines: 1,
          controller: nameController,
        ),
        DropdownButton(
          borderRadius: BorderRadius.circular(20),
          value: selectedCategory,
          hint: const Text('Select Category'),
          onChanged: (String? value) {
            setState(() {
              selectedCategory = value;
              categoryController.text = value ?? '';
            });
          },
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlue,
                ),
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload'),
                onPressed: () async {
                  if (pdfSize <= 5) {
                    await uploadPdf(File(widget.path));
                  } else {
                    Dialogs.showErrorSnackBar(context,
                        'Kindly upload file of size less than or equal to 5MB.');
                  }
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlue,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(mq.width * .1),
          child: Text(
            pdfSize > 5
                ? 'File size: ${pdfSize.toStringAsFixed(2)} MB\n\nKindly upload PDFs of size less than or equal to 5MB.'
                : 'It is recommended to upload PDFs of compressed size (<= 5MB).',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // for uploading pdfs
  Future<String> uploadPdf(File file) async {
    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return '';
    }
    setState(() {
      loading = true;
    });
    String downloadLink = '';

    // storage file reference with path
    final ref = APIs.storage
        .ref()
        .child('PDFs/${categoryController.text}/${nameController.text}.pdf');

    // for uploading file
    final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          customMetadata: {
            'pdfId': DateTime.now().toString(),
            'uploader': APIs.user.uid,
          },
        ));

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
          await APIs.updateUploads(widget.userId, 1);

          final pdfInfo = PDF(
            event.metadata?.customMetadata?['pdfId'],
            nameController.text,
            event.metadata?.customMetadata?['uploader'],
            categoryController.text,
            [],
          );
          await APIs.firestore
              .collection('pdfs')
              .doc(event.metadata?.customMetadata?['pdfId'])
              .set(pdfInfo.toJson());

          Dialogs.showSnackBar(context, 'PDF uploaded successfully!');
          Navigator.pop(context);
          downloadLink = await ref.getDownloadURL();
          log('Pdf uploaded successfully!');
          log('Uploader: ${event.metadata?.customMetadata?['uploader']}');
          break;
      }
    });
    return downloadLink;
  }
}
