import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String title;
  final String playlistLink;

  const YoutubePlayerScreen(
      {Key? key, required this.title, required this.playlistLink})
      : super(key: key);

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  final YoutubeExplode yt = YoutubeExplode();
  List<Video> playlistVideos = [];
  bool isLoading = true;
  double playbackRate = 1.0;
  bool isFullscreen = false;
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

  Future<void> _fetchPlaylistVideos(String playlistUrl) async {
    try {
      final playlistId = PlaylistId.parsePlaylistId(playlistUrl);
      final videos = await yt.playlists.getVideos(playlistId).toList();

      setState(() {
        playlistVideos = videos;
        isLoading = false;
      });

      // Initialize the first video in the playlist
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videos[0].id.value,
        autoPlay: false,
        params: const YoutubePlayerParams(showControls: true),
      );
    } catch (e) {
      print('Error fetching playlist videos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPlaybackOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          height: 100,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      'Playback Speed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: DropdownButton<double>(
                      value: playbackRate, // Use the main state variable
                      items: [0.25, 0.5, 1.0, 1.5, 2.0]
                          .map((rate) => DropdownMenuItem(
                                value: rate,
                                child: Text(
                                  '$rate ×',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      onChanged: (rate) {
                        if (rate != null) {
                          _controller.setPlaybackRate(rate);
                          setState(() {
                            playbackRate = rate; // Update the main state
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });

    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
    _fetchPlaylistVideos(widget.playlistLink);
  }

  @override
  void dispose() {
    _controller.close();
    yt.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullscreen
          ? null
          : AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
                icon: const Icon(CupertinoIcons.chevron_back),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _toggleFullscreen(),
                  tooltip: 'Toggle Fullscreen',
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
                IconButton(
                  onPressed: _showPlaybackOptions,
                  tooltip: 'Video Settings',
                  icon: const Icon(CupertinoIcons.gear),
                ),
              ],
            ),
      bottomNavigationBar: isFullscreen
          ? null
          : isBannerLoaded
              ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
              : const SizedBox(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : playlistVideos.isEmpty
              ? const Center(child: Text("No videos found in the playlist."))
              : Stack(
                  children: [
                    Column(
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          aspectRatio: isFullscreen ? 16 / 7.44 : 16 / 9,
                        ),
                        if (!isFullscreen) ...[
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: playlistVideos.length,
                              itemBuilder: (context, index) {
                                final video = playlistVideos[index];
                                return ListTile(
                                  leading:
                                      Image.network(video.thumbnails.lowResUrl),
                                  title: Text(
                                    video.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    video.author,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  onTap: () {
                                    _controller.loadVideoById(
                                      videoId: video.id.value,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                    if (isFullscreen)
                      Positioned(
                        top: 16,
                        right: 75,
                        child: IconButton(
                            onPressed: _toggleFullscreen,
                            icon: const Icon(
                              Icons.fullscreen_exit_rounded,
                              color: Colors.white,
                            )),
                      ),
                  ],
                ),
    );
  }
}
