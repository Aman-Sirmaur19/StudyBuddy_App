import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../main.dart';
import '../../widgets/custom_navigation.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/particle_animation.dart';
import 'youtube_player_screen.dart';

class Playlists extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const Playlists({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  Future<Map<String, dynamic>?> _fetchPlaylists() async {
    try {
      DocumentSnapshot document =
          await FirebaseFirestore.instance.collection('youtube').doc(id).get();

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>?;
        return data?['playlists'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching playlists: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                Flexible(
                  child: Text(
                    title,
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
                    imageUrl: imageUrl,
                    width: mq.width * .11,
                  ),
                ),
              ],
            )),
        bottomNavigationBar: const CustomBannerAd(),
        body: Stack(
          children: [
            particles(context),
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchPlaylists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                final Map<String, dynamic> playlists = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    String key = playlists.keys.elementAt(index);
                    dynamic value = playlists[key];
                    return InkWell(
                      onTap: () => CustomNavigation().navigateWithAd(
                          context,
                          YoutubePlayerScreen(
                            title: key,
                            playlistLink: value,
                          )),
                      borderRadius: BorderRadius.circular(30),
                      child: GlassContainer(
                        color1: Colors.redAccent.shade200,
                        color2: Colors.red.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            key,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
