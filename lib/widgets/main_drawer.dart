import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:prep_night/screens/leaderboard_screen.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../main.dart';
import '../providers/my_themes.dart';
import '../screens/profile_screen.dart';
import './change_theme_button.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = APIs.me.name;
    final image = APIs.me.image;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final img = FluttermojiFunctions().decodeFluttermojifromString(image);
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          height: mq.height * .15,
          alignment: Alignment.centerLeft,
          color: Theme.of(context).colorScheme.secondary,
          child: Row(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: mq.height * .01, left: mq.width * .05),
                child: Text(
                  name == '' ? 'Let\'s Study!' : 'Hi ${name.split(' ').first}!',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      color: Colors.yellow),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
                child: image != ''
                    ? SizedBox(
                        width: mq.width * .15, child: SvgPicture.string(img))
                    : Image.asset('assets/images/book.png', width: 50),
              ),
            ],
          ),
        ),
        SizedBox(height: mq.height * .03),
        ListTile(
          leading: GlowIcon(
            themeProvider.isDarkMode
                ? Icons.lightbulb
                : Icons.lightbulb_outline_rounded,
            size: 26,
            color:
                themeProvider.isDarkMode ? Colors.yellowAccent : Colors.black,
          ),
          title: Text(
            themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          trailing: const ChangeThemeButton(),
        ),
        buildListTile(
          'About',
          Icons.person,
          () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: APIs.me)));
          },
        ),
        buildListTile(
          'Check for updates!',
          Icons.download_outlined,
          () {},
        ),
        buildListTile(
          'Leaderboard',
          Icons.leaderboard_outlined,
          () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => LeaderboardScreen()));
          },
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.outlined(
                    icon: const GlowIcon(Icons.payments_outlined,
                        color: Colors.green),
                    constraints:
                        const BoxConstraints(minWidth: 50, minHeight: 50),
                    onPressed: () {},
                  ),
                ),
                const Text('Donate Now!'),
                const Text(''),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.outlined(
                    icon: const GlowIcon(Icons.share, color: Colors.lightBlue),
                    constraints:
                        const BoxConstraints(minWidth: 50, minHeight: 50),
                    onPressed: () {},
                  ),
                ),
                const Text('Share with your'),
                const Text('friends!'),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.outlined(
                    icon: const GlowIcon(Icons.star_rate_outlined,
                        color: Colors.redAccent),
                    iconSize: 30,
                    constraints:
                        const BoxConstraints(minWidth: 50, minHeight: 50),
                    onPressed: () {},
                  ),
                ),
                const Text('Rate us!'),
                const Text(''),
              ],
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: mq.height * .02),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.copyright_rounded),
              Text(
                'Aman Sirmaur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
