import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttermoji/fluttermojiFunctions.dart';

import '../main.dart';
import '../api/apis.dart';
import '../models/main_user.dart';
import '../widgets/custom_banner_ad.dart';
import '../widgets/particle_animation.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<MainUser> _list = [];

  @override
  void initState() {
    super.initState();
    APIs.getAllUsers();
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            Container(
              width: mq.width * .12,
              margin: const EdgeInsets.only(left: 5),
              child: Image.asset(
                'assets/images/leaderboard.png',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: Stack(
        children: [
          particles(context),
          StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  // if data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => MainUser.fromJson(e.data()))
                            .toList() ??
                        [];
                    _list.sort((a, b) => b.uploads.compareTo(a.uploads));
                    int count = 0;
                    for (var i in _list) {
                      if (i.uploads > 0) {
                        count++;
                        break;
                      }
                    }

                    if (count != 0) {
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: mq.width * .017, right: mq.width * .005),
                            child: ListTile(
                              leading: const Text(
                                'Rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: mq.width * .07),
                                child: const Text(
                                  'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              trailing: const Text(
                                'Uploads',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                final img = FluttermojiFunctions()
                                    .decodeFluttermojifromString(
                                        _list[index].image);

                                return _list[index].uploads > 0
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: mq.width * .02),
                                        child: Card(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: ListTile(
                                            leading: index < 3
                                                ? Image.asset(
                                                    'assets/images/$index-medal.png',
                                                    width: mq.width * .065,
                                                  )
                                                : Text(
                                                    (index + 1).toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                            title: Padding(
                                              padding: EdgeInsets.only(
                                                  left: mq.width * .07),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    _list[index]
                                                        .name
                                                        .split(' ')
                                                        .first,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: mq.width * .01),
                                                    child: SvgPicture.string(
                                                        img,
                                                        width: mq.width * .09),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            trailing: Container(
                                              margin: EdgeInsets.only(
                                                  right: mq.width * .04),
                                              child: Text(
                                                _list[index].uploads.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null;
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: mq.height * .1),
                          child: Column(
                            children: [
                              const Text(
                                'Nobody has uploaded yet!',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: mq.height * .03),
                              Image.asset(
                                'assets/images/leaderboard.png',
                                height: mq.height * .4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                }
              }),
        ],
      ),
    );
  }
}
