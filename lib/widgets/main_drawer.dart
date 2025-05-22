import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../main.dart';
import '../helper/dialogs.dart';
import '../providers/my_themes.dart';
import '../widgets/particle_animation.dart';

import './change_theme_button.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onTap: tapHandler,
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final name = APIs.me.name;
    // final image = APIs.me.image;
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final img = FluttermojiFunctions().decodeFluttermojifromString(image);
    return Drawer(
        child: Stack(
      children: [
        particles(context),
        Column(
          children: <Widget>[
            Container(
              height: mq.height * .15,
              alignment: Alignment.centerLeft,
              color: Theme.of(context).colorScheme.primary,
              child: Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: mq.height * .01, left: mq.width * .05),
                      child: Text(
                        'Let\'s Study!',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            color: themeProvider.isDarkMode
                                ? Colors.yellow.shade800
                                : Colors.blue.shade800),
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
                    child: Image.asset('assets/images/book.png', width: 50),
                  ),
                ],
              ),
            ),
            SizedBox(height: mq.height * .03),
            ListTile(
              leading: GlowIcon(
                themeProvider.isDarkMode
                    ? CupertinoIcons.lightbulb_fill
                    : CupertinoIcons.lightbulb,
                size: 26,
                color: themeProvider.isDarkMode
                    ? Colors.yellowAccent
                    : Colors.black,
              ),
              title: Text(
                themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: const ChangeThemeButton(),
            ),
            // buildListTile(
            //   'About',
            //   CupertinoIcons.person,
            //   () {
            //     Navigator.push(
            //         context,
            //         CupertinoPageRoute(
            //             builder: (_) => ProfileScreen(user: APIs.me)));
            //   },
            // ),
            // if (APIs.user.email == 'amansirmaur190402@gmail.com')
            //   ListTile(
            //     leading: const Icon(Icons.picture_as_pdf_outlined, size: 26),
            //     title: const Text(
            //       'PDF Compressor',
            //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //     ),
            //     subtitle: const Text(
            //       '(recommended app, not a paid promotion)',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           letterSpacing: 1,
            //           color: Colors.grey),
            //     ),
            //     onTap: () {
            //       const url = 'https://www.freeconvert.com/compress-pdf';
            //       setState(() {
            //         _launchInBrowser(Uri.parse(url));
            //       });
            //     },
            //   ),
            buildListTile(
              'More Apps!',
              CupertinoIcons.app_badge,
              () {
                const url =
                    'https://play.google.com/store/apps/developer?id=SIRMAUR';
                setState(() {
                  _launchInBrowser(Uri.parse(url));
                });
              },
            ),
            buildListTile(
              'Copyright',
              Icons.copyright_rounded,
              () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: themeProvider.isDarkMode
                          ? const Color(0xFF444446)
                          : null,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(mq.width * .15),
                            child: Image.asset(
                              'assets/images/avatar.png',
                              width: mq.width * .3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Aman Sirmaur',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: mq.width * .01),
                            child: Text(
                              'MECHANICAL ENGINEERING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: mq.width * .03),
                            child: Text(
                              'NIT AGARTALA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.secondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            child: Image.asset('assets/images/linkedin.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.linkedin.com/in/aman-kumar-257613257/';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/github.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url = 'https://github.com/Aman-Sirmaur19';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/instagram.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.instagram.com/aman_sirmaur19/';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/twitter.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/youtube.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.youtube.com/@AmanSirmaur';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close',
                              style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondary)),
                        ),
                      ],
                    );
                  }),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  _customAppListTile(
                    appLink:
                        'https://play.google.com/store/apps/details?id=com.sirmaur.attendance_tracker',
                    imageUrl:
                        'https://play-lh.googleusercontent.com/yM6xx4rQUYU583yQxBh8uze0nipScuPbRDMMC53Z_O-iw2D-Whq7pCW3DHRZGDlXbDo=w480-h960-rw',
                    firstName: 'Attendance',
                    lastName: 'Tracker',
                    firstColor: Colors.lightBlue,
                    lastColor: Colors.amber.shade700,
                    subtitle: 'Track your college attendance',
                  ),
                  const SizedBox(height: 5),
                  _customAppListTile(
                    appLink:
                        'https://play.google.com/store/apps/details?id=com.sirmaur.habito',
                    imageUrl:
                        'https://play-lh.googleusercontent.com/6pVzCQ-zskiVRkDHCfplR_2JNIUgotMHc_5wGG3EsQR9maMJeIoIhWjpkk4qyR_-UZ5a=w480-h960-rw',
                    firstName: 'Habit ',
                    lastName: 'Tracker',
                    firstColor: Colors.lightBlue,
                    lastColor: Colors.red,
                    subtitle: 'Track your daily habits',
                  ),
                  const SizedBox(height: 5),
                  _customAppListTile(
                    appLink:
                        'https://play.google.com/store/apps/details?id=com.sirmaur.shreemad_bhagavad_geeta',
                    imageUrl:
                        'https://play-lh.googleusercontent.com/L4FMm88yMoWIKhUX3U1XJTmvd8_MkoQUX4IfN61QBSq51GWpnMPvs4Dz7gpmlmXspA=w480-h960-rw',
                    firstName: 'Bhagavad ',
                    lastName: 'Gita',
                    firstColor: Colors.orange.shade600,
                    lastColor: Colors.green,
                    subtitle: 'Listen the Divine Song of God',
                  ),
                ],
              ),
            ),
            const Spacer(),
            // if (APIs.user.email == 'amansirmaur190402@gmail.com')
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: IconButton.outlined(
            //               icon: const GlowIcon(Icons.payments_outlined,
            //                   color: Colors.green),
            //               constraints:
            //                   const BoxConstraints(minWidth: 50, minHeight: 50),
            //               onPressed: () {
            //                 // Navigator.push(
            //                 //     context,
            //                 //     MaterialPageRoute(
            //                 //         builder: (_) => const PaymentScreen()));
            //               },
            //             ),
            //           ),
            //           const Text('Donate Now!'),
            //           const Text(''),
            //         ],
            //       ),
            //       Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: IconButton.outlined(
            //               icon: const GlowIcon(Icons.share,
            //                   color: Colors.lightBlue),
            //               constraints:
            //                   const BoxConstraints(minWidth: 50, minHeight: 50),
            //               onPressed: () {},
            //             ),
            //           ),
            //           const Text('Share with your'),
            //           const Text('friends!'),
            //         ],
            //       ),
            //       Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: IconButton.outlined(
            //               icon: const GlowIcon(Icons.star_rate_outlined,
            //                   color: Colors.redAccent),
            //               iconSize: 30,
            //               constraints:
            //                   const BoxConstraints(minWidth: 50, minHeight: 50),
            //               onPressed: () {},
            //             ),
            //           ),
            //           const Text('Rate us!'),
            //           const Text(''),
            //         ],
            //       ),
            //     ],
            //   ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: mq.height * .02),
              child: const Text('MADE WITH ❤️ IN 🇮🇳',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _customAppListTile({
    required String appLink,
    required String imageUrl,
    required String firstName,
    required String lastName,
    required String subtitle,
    required Color firstColor,
    required Color lastColor,
  }) {
    return ListTile(
      onTap: () async {
        setState(() {
          _launchInBrowser(Uri.parse(appLink));
        });
      },
      contentPadding: const EdgeInsets.only(left: 5),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 45,
          )),
      title: RichText(
          text: TextSpan(
        text: firstName,
        style: TextStyle(
          fontSize: 20,
          color: firstColor,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: lastName,
            style: TextStyle(
              fontSize: 20,
              color: lastColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )),
      subtitle: Text(subtitle),
    );
  }
}
