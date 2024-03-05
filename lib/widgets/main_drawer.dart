import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/my_themes.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                child: const Text(
                  'Let\'s Study!',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      color: Colors.yellow),
                ),
              ),
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
                ? Icons.lightbulb
                : Icons.lightbulb_outline_rounded,
            size: 26,
            color:
                themeProvider.isDarkMode ? Colors.yellowAccent : Colors.black,
          ),
          title: Text(
            themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          trailing: ChangeThemeButton(),
        ),
        buildListTile(
          'About',
          Icons.person,
          () {},
        ),
        buildListTile(
          'Filters',
          Icons.settings,
          () {},
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
                    icon: const GlowIcon(Icons.payments_outlined, color: Colors.green),
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
                    icon: const GlowIcon(Icons.star_rate_outlined, color: Colors.redAccent),
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
