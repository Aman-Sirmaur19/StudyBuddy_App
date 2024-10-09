import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../main.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/particle_animation.dart';

class Playlists extends StatefulWidget {
  final String id;
  final String title;
  final String imageUrl;

  const Playlists({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
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

  Future<Map<String, dynamic>?> fetchPlaylists() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('youtube')
          .doc(widget.id)
          .get();

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>?;
        return data?['playlists'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching playlists: $e");
    }
    return null;
  }

  Future<void> _launchInBrowser(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
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
              Flexible(
                child: Text(
                  widget.title,
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
                  imageUrl: widget.imageUrl,
                  width: mq.width * .11,
                ),
              ),
            ],
          )),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: Stack(
        children: [
          particles(context),
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchPlaylists(),
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
                    onTap: () => _launchInBrowser(Uri.parse(value)),
                    borderRadius: BorderRadius.circular(30),
                    child: GlassContainer(
                      color1: Colors.redAccent.shade200,
                      color2: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              key,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
