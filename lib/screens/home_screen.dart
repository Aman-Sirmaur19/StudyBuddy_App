import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prep_night/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../main.dart';
import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import '../widgets/main_drawer.dart';

import './auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  FilePickerResult? _pickedFile;
  String? _name;
  bool _isPicked = false;

  List<Map<String, dynamic>> pdfData = [];

  // for accessing files
  void getAllPdfs() async {
    final results = await APIs.firestore.collection('PDFs').get();
    pdfData = results.docs.map((e) => e.data()).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllPdfs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllPdfs();
  }

  Future<void> _refresh() async {
    didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GlowIcon(
          CupertinoIcons.home,
          color:
              themeProvider.isDarkMode ? Colors.lightGreenAccent : Colors.green,
        ),
        title: const Text('PrepNight'),
        centerTitle: true,
        actions: [
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
            setState(() {
              _pickedFile = pickedFile;
              _name = pickedFile.files[0].name;
              _isPicked = true;
            });
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: _isPicked
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Do you want to upload ?',
                    style: TextStyle(fontSize: 25),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/images/pdf.png',
                        width: mq.width * .45),
                  ),
                  Text(_name!),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            setState(() {
                              APIs.pickFile(context, _pickedFile);
                              _pickedFile = null;
                              _isPicked = false;
                            });
                          },
                        ),
                        ElevatedButton(
                          child: const Text('No'),
                          onPressed: () {
                            setState(() {
                              _pickedFile = null;
                              _isPicked = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : pdfData.isEmpty
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .25),
                      child: Image.asset('assets/images/study.jpg',
                          width: mq.width * .7),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: pdfData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PdfViewerScreen(
                                      pdfName: pdfData[index]['name'],
                                      pdfUrl: pdfData[index]['url'],
                                    )));
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/images/pdf.png',
                                  width: mq.width * .35),
                              Text(pdfData[index]['name'], maxLines: 1),
                            ],
                          ),
                        ),
                      );
                    },
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
}
