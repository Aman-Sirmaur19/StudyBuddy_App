import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import '../../api/apis.dart';

class PdfViewerScreen extends StatefulWidget {
  final bool? isDownloaded;
  final String pdfName;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.isDownloaded,
    required this.pdfName,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;

  void initialisePdf() async {
    if (widget.isDownloaded == true) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = '${appDocDir.path}/${widget.pdfName}';
      File file = File(appDocPath);
      document = await PDFDocument.fromFile(file);
    } else {
      final url =
          await APIs.storage.ref().child(widget.pdfUrl).getDownloadURL();
      document = await PDFDocument.fromURL(url);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialisePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: Text(
          widget.pdfName.split('.').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: document != null
          ? PDFViewer(document: document!)
          : Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary)),
    );
  }
}
