import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:file_picker/file_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../helper/dialogs.dart';
import '../widgets/main_drawer.dart';

import './auth/auth_screen.dart';
import './pdf_viewer_screen.dart';
import './upload_pdf_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> pdfData = [];
  List<Map<String, dynamic>> pdfDataList = [];

  // for storing search status
  bool _isSearching = false;

  //for storing searched items
  final List<Map<String, dynamic>> _searchList = [];

  // for accessing files
  void getAllPdfs() async {
    final results = await APIs.storage.ref('PDFs').listAll();
    pdfData = await Future.wait(
      results.items
          .where((item) => item.name.endsWith('.pdf'))
          .map((item) async {
        final metadata = await item.getMetadata();
        final uploaderName =
            await APIs.getUserName(metadata.customMetadata!['uploader']!);
        final uploaderId = metadata.customMetadata!['uploader']!;
        final pdfId = metadata.customMetadata!['pdfId']!;
        return {
          'name': item.name,
          'url': item.fullPath,
          'metadata': metadata,
          'uploader': uploaderName,
          'uploaderId': uploaderId,
          'pdfId': pdfId,
        };
      }).toList(),
    );
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchPdfData() async {
    try {
      // Get a reference to the 'pdfs' collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('pdfs').get();

      // Convert the QuerySnapshot into a List<Map<String, dynamic>>
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> pdfInfo = doc.data();
        pdfInfo['pdfId'] = doc.id; // Add the document ID to the data
        pdfDataList.add(pdfInfo);
      }

      return pdfDataList;
    } catch (e) {
      print("Error fetching PDF data: $e");
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    getAllPdfs();
    fetchPdfData();
  }

  Future<void> _refresh() async {
    getAllPdfs();
    fetchPdfData();
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
            title: _isSearching
                ? TextField(
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
                : const Text('PrepNight'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : CupertinoIcons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
              ),
              IconButton(
                icon: const GlowIcon(Icons.logout, color: Colors.redAccent),
                onPressed: showAlertDialog,
              )
            ],
          ),
          drawer: const MainDrawer(),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.upload_file_outlined),
            onPressed: () async {
              final pickedFile = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
                allowCompression: true,
              );
              if (pickedFile != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadPdfScreen(
                      pickedFile: pickedFile,
                      name: pickedFile.files[0].name,
                      path: pickedFile.files[0].path!,
                    ),
                  ),
                );
              }
            },
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(),
            child: pdfData.isEmpty ? _pdfDataIsEmpty() : _pdfDataIsNotEmpty(),
          ),
        ),
      ),
    );
  }

  Future showAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Do you want to logout?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () async {
                    // for showing progress dialog
                    Dialogs.showProgressBar(context);

                    // sign out from app
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AuthScreen()));
                    });
                  },
                ),
                TextButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        });
  }

  Widget _pdfDataIsEmpty() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(mq.width * .25),
        child: Image.asset('assets/images/study.jpg', width: mq.width * .7),
      ),
    );
  }

  Widget _pdfDataIsNotEmpty() {
    return ListView.builder(
      itemCount: _isSearching ? _searchList.length : pdfData.length,
      itemBuilder: (context, index) {
        int i = pdfDataList.indexWhere((element) =>
            element['pdfId'].toString() == pdfData[index]['pdfId']);
        bool userLiked =
            pdfDataList[i]['likes']?.contains(APIs.user.uid) ?? false;
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                        pdfName: _isSearching
                            ? _searchList[index]['name']
                            : pdfData[index]['name'],
                        pdfUrl: _isSearching
                            ? _searchList[index]['url']
                            : pdfData[index]['url'],
                      )));
            },
            child: ListTile(
              leading:
                  Image.asset('assets/images/pdf.png', width: mq.width * .15),
              title: Text(
                _isSearching
                    ? _searchList[index]['name'].split('.').first
                    : pdfData[index]['name'].split('.').first,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Text(
                    _isSearching
                        ? _searchList[index]['uploader']
                        : pdfData[index]['uploader'],
                    style: const TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: mq.width * .03),
                    child: IconButton(
                      color: Colors.blue,
                      icon: userLiked
                          ? const Icon(Icons.thumb_up_alt_rounded)
                          : const Icon(Icons.thumb_up_alt_outlined),
                      onPressed: () async {
                        final pdfRef = APIs.firestore
                            .collection('pdfs')
                            .doc(pdfData[index]['pdfId']);
                        final docSnapshot = await pdfRef.get();
                        final currentLikes =
                            List<String>.from(docSnapshot.data()?['likes']);
                        if (!currentLikes.contains(APIs.user.uid)) {
                          currentLikes.add(APIs.user.uid);
                          await pdfRef.update({'likes': currentLikes});
                          setState(() {
                            pdfDataList[i]['likes']?.add(APIs.user.uid);
                            userLiked = true;
                          });
                        } else {
                          currentLikes.remove(APIs.user.uid);
                          await pdfRef.update({'likes': currentLikes});
                          setState(() {
                            pdfDataList[i]['likes']?.remove(APIs.user.uid);
                            userLiked = false;
                          });
                        }
                      },
                    ),
                  ),
                  Text(pdfDataList[i]['likes'].length.toString(),
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  if (APIs.user.uid == pdfData[index]['uploaderId'])
                    Padding(
                      padding: EdgeInsets.only(left: mq.width * .03),
                      child: IconButton(
                        color: Colors.red,
                        icon: const Icon(Icons.delete_rounded),
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
                                      child: const Text('Yes'),
                                      onPressed: () async {
                                        await APIs.firestore
                                            .collection('pdfs')
                                            .doc(pdfData[index]['pdfId'])
                                            .delete();
                                        await APIs.storage
                                            .ref()
                                            .child(
                                                'PDFs/${pdfData[index]['name']}')
                                            .delete()
                                            .then((value) =>
                                                Dialogs.showSnackBar(context,
                                                    'Deleted successfully!'));
                                        Navigator.pop(context);
                                        _refresh();
                                      },
                                    ),
                                    TextButton(
                                        child: const Text('No'),
                                        onPressed: () =>
                                            Navigator.pop(context)),
                                  ],
                                ),
                              );
                            }),
                      ),
                    )
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }
}
