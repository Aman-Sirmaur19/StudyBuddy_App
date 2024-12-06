import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

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
  Future<String>? pdfPathFuture;
  PDFViewController? _pdfViewController;
  int? _totalPages;
  bool isBannerLoaded = false;
  late BannerAd bannerAd;

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
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  void _goToPageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController pageController = TextEditingController();

        return AlertDialog(
          title: const Text('Go to Page'),
          content: TextField(
            controller: pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Enter page no. (1 - $_totalPages)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.blue)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final page = int.tryParse(pageController.text);
                if (page != null &&
                    page > 0 &&
                    (_totalPages == null || page <= _totalPages!)) {
                  _pdfViewController
                      ?.setPage(page - 1); // Page indices are zero-based
                }
                Navigator.of(context).pop();
              },
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.blue)),
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
    pdfPathFuture = _initialisePdf();
  }

  Future<String> _initialisePdf() async {
    try {
      if (widget.isDownloaded == true) {
        final appDocDir = await getApplicationDocumentsDirectory();
        return '${appDocDir.path}/${widget.pdfName}';
      } else {
        return await APIs.storage.ref().child(widget.pdfUrl).getDownloadURL();
      }
    } catch (e) {
      return e.toString();
    }
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
        actions: [
          IconButton(
            onPressed: _goToPageDialog,
            tooltip: 'Go to Page',
            icon: const Icon(CupertinoIcons.doc_text_search),
          ),
        ],
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: FutureBuilder<String>(
        future: pdfPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Invalid PDF path.'));
          }

          final path = snapshot.data!;
          return widget.isDownloaded!
              ? PDF(
                  enableSwipe: true,
                  swipeHorizontal: true,
                  onViewCreated: (controller) {
                    _pdfViewController = controller;
                  },
                  onPageChanged: (currentPage, totalPages) {
                    setState(() {
                      _totalPages = totalPages;
                    });
                  },
                ).fromPath(path)
              : PDF(
                  enableSwipe: true,
                  swipeHorizontal: true,
                  onViewCreated: (controller) {
                    _pdfViewController = controller;
                  },
                  onPageChanged: (currentPage, totalPages) {
                    setState(() {
                      _totalPages = totalPages;
                    });
                  },
                ).cachedFromUrl(
                  path,
                  placeholder: (progress) => Center(
                      child: Text(
                    '$progress %\nLoading',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )),
                  errorWidget: (error) => const Center(
                      child: Text(
                    'Kindly check your internet connection!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  )),
                );
        },
      ),
    );
  }
}
