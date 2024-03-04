import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:prep_night/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import 'auth_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => AuthScreen()));
    });
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
      drawer: MainDrawer(),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(mq.width * .25),
          child: Image.asset('assets/images/study.jpg', width: mq.width * .7),
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
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => AuthScreen()));
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
