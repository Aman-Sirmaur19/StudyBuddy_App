import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/glass_container.dart';
import '../../widgets/particle_animation.dart';
import 'playlists.dart';

class AllYoutubeScreen extends StatefulWidget {
  const AllYoutubeScreen({super.key});

  @override
  State<AllYoutubeScreen> createState() => _AllYoutubeScreenState();
}

class _AllYoutubeScreenState extends State<AllYoutubeScreen> {
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

  Future<List<Map<String, dynamic>>> fetchAllYoutubeTopics() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('youtube').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching YouTube topics: $e');
    }
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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Tube',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchAllYoutubeTopics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No YouTube topics found.'));
              }

              final youtubeTopics = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemCount: youtubeTopics.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Playlists(
                                  id: youtubeTopics[index]['id'],
                                  title: youtubeTopics[index]['name'],
                                  imageUrl: youtubeTopics[index]['url'],
                                ))),
                    borderRadius: BorderRadius.circular(30),
                    child: GlassContainer(
                      color1: Colors.redAccent.shade200,
                      color2: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CachedNetworkImage(
                            imageUrl: youtubeTopics[index]['url'],
                            width: 40,
                          ),
                          Text(
                            youtubeTopics[index]['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
