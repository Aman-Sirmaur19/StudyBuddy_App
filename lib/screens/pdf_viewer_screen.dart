import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import '../api/apis.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfName, pdfUrl;

  const PdfViewerScreen(
      {super.key, required this.pdfName, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;

  void initialisePdf() async {
    final url = await APIs.storage.ref().child(widget.pdfUrl).getDownloadURL();
    document = await PDFDocument.fromURL(url);
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
        centerTitle: true,
        title: Text(
          widget.pdfName.split('.').first,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: document != null
          ? PDFViewer(document: document!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
