import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../main.dart';
import '../../api/apis.dart';
import '../../providers/permission.dart';
import '../../helper/dialogs.dart';
import '../../widgets/chart_bar.dart';

import '../../widgets/particle_animation.dart';
import 'pdf_viewer_screen.dart';

class PdfScreen extends StatefulWidget {
  final Map<String, dynamic> branch;

  const PdfScreen({super.key, required this.branch});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  BuildContext? _scaffoldContext;
  bool isBanner1Loaded = false;
  bool isBanner2Loaded = false;
  late BannerAd bannerAd1;
  late BannerAd bannerAd2;

  bool isInterstitialLoaded = false;
  late InterstitialAd interstitialAd;

  Map<String, bool> downloading = {};
  Map<String, bool> fileExists = {};
  Map<String, double> progress = {};
  Map<String, CancelToken> cancelTokens = {};

  List<Map<String, dynamic>> pdfData = [];

  bool _isLoading = true;
  bool _isDeleting = false;

  // for storing search status
  bool _isSearching = false;

  //for storing searched items
  final List<Map<String, dynamic>> _searchList = [];

  initializeBannerAd() async {
    bannerAd1 = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8331104249',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBanner1Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBanner1Loaded = false;
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd2 = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8331104249',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBanner2Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBanner2Loaded = false;
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd1.load();
    bannerAd2.load();
  }

  initializeInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9389901804535827/9271623155',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          setState(() {
            isInterstitialLoaded = true;
          });
          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              initializeInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              initializeInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log(error.message);
          interstitialAd.dispose();
          setState(() {
            isInterstitialLoaded = false;
          });
        },
      ),
    );
  }

  // for accessing files
  void getAllPdfs() async {
    final results =
        await APIs.storage.ref('PDFs/${widget.branch['name']}').listAll();
    pdfData = await Future.wait(
      results.items
          .where((item) => item.name.endsWith('.pdf'))
          .map((item) async {
        final downloadUrl = await item.getDownloadURL();
        final metadata = await item.getMetadata();
        final uploaderId = metadata.customMetadata!['uploader']!;
        // final uploaderName = await APIs.getUserName(uploaderId);
        final pdfId = metadata.customMetadata!['pdfId']!;
        return {
          'name': item.name,
          'url': item.fullPath,
          'metadata': metadata,
          // 'uploader': uploaderName,
          'uploaderId': uploaderId,
          'pdfId': pdfId,
          'downloadUrl': downloadUrl,
        };
      }).toList(),
    );

    // Initialize the download state maps and check if the file is downloaded
    for (var pdf in pdfData) {
      bool fileDownloaded = await checkFileDownloaded(pdf['name']);
      setState(() {
        downloading[pdf['name']] = false;
        fileExists[pdf['name']] = fileDownloaded;
        progress[pdf['name']] = 0.0;
        cancelTokens[pdf['name']] = CancelToken();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
    initializeInterstitialAd();
    getAllPdfs();
    // fetchPdfData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldContext = context;
  }

  Future<void> _refresh() async {
    getAllPdfs();
    // fetchPdfData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvoked: (bool _) {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              icon: const Icon(CupertinoIcons.chevron_back),
            ),
            title: _isSearching
                ? TextField(
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter PDF name...',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 1),

                    // when search text changes, update search list
                    onChanged: (val) {
                      // search logic
                      _searchList.clear();
                      for (var i in pdfData) {
                        if (i['name']
                            .toLowerCase()
                            .contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.branch['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: CachedNetworkImage(
                          imageUrl: widget.branch['url'],
                          width: mq.width * .11,
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : CupertinoIcons.search),
                tooltip: _isSearching ? 'Close' : 'Search',
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
              ),
            ],
          ),
          bottomNavigationBar: isBanner2Loaded
              ? SizedBox(height: 50, child: AdWidget(ad: bannerAd2))
              : const SizedBox(),
          body: Stack(
            children: [
              particles(context),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary),
                    )
                  : pdfData.isEmpty
                      ? SingleChildScrollView(child: _pdfDataIsEmpty())
                      : _pdfDataIsNotEmpty(),
              if (_isDeleting)
                Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary))
            ],
          ),
        ),
      ),
    );
  }

  Widget _pdfDataIsEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: mq.height * .07),
        child: Column(
          children: [
            isBanner1Loaded
                ? SizedBox(height: 50, child: AdWidget(ad: bannerAd1))
                : const SizedBox(),
            Padding(
              padding: EdgeInsets.only(bottom: mq.height * .04),
              child: const Text(
                'Nothing uploaded yet!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.branch['url'],
              width: mq.width * .5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pdfDataIsNotEmpty() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _isSearching ? _searchList.length : pdfData.length,
      itemBuilder: (context, index) {
        return Card(
            child: InkWell(
          onTap: () {
            if (isInterstitialLoaded) interstitialAd.show();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => PdfViewerScreen(
                      isDownloaded: fileExists[pdfData[index]['name']],
                      pdfName: _isSearching
                          ? _searchList[index]['name']
                          : pdfData[index]['name'],
                      pdfUrl: _isSearching
                          ? _searchList[index]['url']
                          : pdfData[index]['url'],
                    )));
          },
          child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: widget.branch['url'],
                width: mq.width * .07,
              ),
              title: Text(
                _isSearching
                    ? _searchList[index]['name'].split('.').first
                    : pdfData[index]['name'].split('.').first,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: (downloading[pdfData[index]['name']]!)
                  ? LinearProgressBar(
                      fraction: progress[pdfData[index]['name']]!,
                      color: Colors.blue.withOpacity(.7),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  downloading[pdfData[index]['name']]!
                      ? IconButton(
                          tooltip: 'Cancel download',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            cancelDownload(pdfData[index]['name']);
                          },
                        )
                      : fileExists[pdfData[index]['name']] == true
                          ? IconButton(
                              tooltip: 'View',
                              onPressed: () {
                                if (isInterstitialLoaded) interstitialAd.show();
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) => PdfViewerScreen(
                                          isDownloaded: fileExists[
                                              pdfData[index]['name']],
                                          pdfName: _isSearching
                                              ? _searchList[index]['name']
                                              : pdfData[index]['name'],
                                          pdfUrl: _isSearching
                                              ? _searchList[index]['url']
                                              : pdfData[index]['url'],
                                        )));
                              },
                              icon: const Icon(Icons.remove_red_eye_outlined))
                          : IconButton(
                              tooltip: 'Download',
                              icon: const Icon(Icons.file_download_outlined),
                              onPressed: () async {
                                if (isInterstitialLoaded) {
                                  interstitialAd.show();
                                }
                                // bool permission = false;
                                // if (!permission) {
                                //   permission = await CheckPermission
                                //       .isStoragePermission();
                                // }
                                downloadFile(
                                  index,
                                  (received, total) {
                                    setState(() {
                                      progress[pdfData[index]['name']] =
                                          received / total;
                                    });
                                  },
                                );
                              },
                            ),
                  if (APIs.user.uid == pdfData[index]['uploaderId'] ||
                      APIs.user.email == 'amansirmaur190402@gmail.com')
                    IconButton(
                      tooltip: 'Delete',
                      color: Colors.red,
                      icon: const Icon(CupertinoIcons.delete_solid),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Do you want to delete?',
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    child: Text('Yes',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary)),
                                    onPressed: () => _deletePdf(index),
                                  ),
                                  TextButton(
                                      child: Text('No',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary)),
                                      onPressed: () => Navigator.pop(context)),
                                ],
                              ),
                            );
                          }),
                    )
                ],
              )),
        ));
      },
    );
  }

  Future<bool> checkFileDownloaded(String name) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = '${appDocDir.path}/$name';
    bool check = await File(appDocPath).exists();
    log(check.toString());
    return check;
  }

  // void openFile(String name) async {
  //   final appDocDir = await getApplicationDocumentsDirectory();
  //   final appDocPath = '${appDocDir.path}/$name';
  //   final result = await OpenFilex.open(appDocPath);
  //   if (result.type != ResultType.done) {
  //     Dialogs.showErrorSnackBar(context, result.message);
  //     log('Error opening file: ${result.message}');
  //   }
  // }

  Future<void> deleteFileIfExists(String name) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = '${appDocDir.path}/$name';
    final file = File(appDocPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> downloadFile(
    int index,
    Function(double, double) onProgress,
  ) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = '${appDocDir.path}/${pdfData[index]['name']}';
    await deleteFileIfExists(pdfData[index]['name']);
    Dio dio = Dio();
    setState(() {
      downloading[pdfData[index]['name']] = true;
    });
    try {
      cancelTokens[pdfData[index]['name']] = CancelToken();
      await dio.download(
        pdfData[index]['downloadUrl'],
        appDocPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received.toDouble(), total.toDouble());
          }
        },
        cancelToken: cancelTokens[pdfData[index]['name']]!,
      );
      log(appDocPath);
      Dialogs.showSnackBar(context, 'Downloaded successfully!');
      setState(() {
        fileExists[pdfData[index]['name']] = true;
      });
    } catch (e) {
      log('Download failed: $e');
      Dialogs.showErrorSnackBar(context, 'Download failed!');
    } finally {
      setState(() {
        downloading[pdfData[index]['name']] = false;
        progress[pdfData[index]['name']] = 0.0;
      });
    }
  }

  void cancelDownload(String name) {
    cancelTokens[name]?.cancel();
    setState(() {
      downloading[name] = false;
      progress[name] = 0.0;
    });
  }

  void _deletePdf(int index) async {
    Navigator.pop(context);

    setState(() {
      _isDeleting = true;
    });

    try {
      String path = 'PDFs/${widget.branch['name']}/${pdfData[index]['name']}';
      await APIs.storage.ref().child(path).delete();
      await APIs.updateUploads(pdfData[index]['uploaderId'], -1);
      setState(() {
        _isDeleting = false;
      });
      _refresh();
      if (_scaffoldContext != null) {
        Dialogs.showSnackBar(_scaffoldContext!, 'Deleted successfully!');
      }
    } catch (error) {
      setState(() {
        _isDeleting = false;
      });
      if (_scaffoldContext != null) {
        Dialogs.showErrorSnackBar(_scaffoldContext!, 'Deletion failed!');
      }
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
