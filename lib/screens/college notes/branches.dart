import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/my_themes.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/particle_animation.dart';
import 'pdf_screen.dart';

class AllBranchesScreen extends StatefulWidget {
  const AllBranchesScreen({super.key});

  @override
  State<AllBranchesScreen> createState() => _AllBranchesScreenState();
}

class _AllBranchesScreenState extends State<AllBranchesScreen> {
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

  Future<List<Map<String, dynamic>>> fetchAllBranches() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('branches').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching branches: $e');
    }
  }

  void selectBranch(BuildContext ctx, Map<String, dynamic> branch) {
    Navigator.of(ctx)
        .push(CupertinoPageRoute(builder: (ctx) => PdfScreen(branch: branch)));
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const Text(
            'All Branches',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          )),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: Stack(
        children: [
          particles(context),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchAllBranches(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No branches found.'));
              }

              final branches = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => selectBranch(context, branches[index]),
                    borderRadius: BorderRadius.circular(30),
                    child: GlassContainer(
                      color1:
                          themeProvider.isDarkMode ? Colors.white : Colors.blue,
                      color2: themeProvider.isDarkMode
                          ? Colors.white10
                          : Colors.blue.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CachedNetworkImage(
                            imageUrl: branches[index]['url'],
                            width: 40,
                          ),
                          Text(
                            branches[index]['name'],
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
