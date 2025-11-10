import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../widgets/custom_banner_ad.dart';

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
  YoutubePlayerController? _controller;
  final YoutubeExplode yt = YoutubeExplode();
  List<Video> playlistVideos = [];
  bool isLoading = true;
  double playbackRate = 1.0;
  bool isFullscreen = false;

  Future<void> _fetchPlaylistVideos(String playlistUrl) async {
    setState(() {
      isLoading = true;
    });
    try {
      final playlistId = PlaylistId.parsePlaylistId(playlistUrl);
      final videos = await yt.playlists.getVideos(playlistId).toList();
      setState(() {
        playlistVideos = videos;
        isLoading = false;
      });
      if (videos.isNotEmpty) {
        _controller?.loadVideoById(videoId: videos[0].id.value);
      }
    } catch (e) {
      print('Error fetching playlist videos: $e');
      setState(() {
        isLoading = false;
      });
    }
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
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        origin: 'https://www.youtube-nocookie.com', // The fix for Error 150
      ),
    );
    _fetchPlaylistVideos(widget.playlistLink.trim());
  }

  @override
  void dispose() {
    _controller?.close();
    yt.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                ],
              ),
        bottomNavigationBar: isFullscreen ? null : const CustomBannerAd(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : playlistVideos.isEmpty
                ? const Center(child: Text("No videos found in the playlist."))
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ListView(
                        children: [
                          // YoutubePlayer(
                          //   controller: _controller!,
                          //   aspectRatio: isFullscreen ? 16 / 7.44 : 16 / 9,
                          // ),
                          _controller == null
                              ? const SizedBox.shrink()
                              : YoutubePlayer(
                                  controller: _controller!,
                                  aspectRatio:
                                      isFullscreen ? 16 / 7.44 : 16 / 9,
                                ),
                          if (!isFullscreen) ...[
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                    _controller?.loadVideoById(
                                      videoId: video.id.value,
                                    );
                                  },
                                );
                              },
                            ),
                          ]
                        ],
                      ),
                      if (isFullscreen)
                        Positioned(
                          bottom: 60,
                          right: 10,
                          child: IconButton(
                              onPressed: _toggleFullscreen,
                              tooltip: 'End Fullscreen',
                              icon: const Icon(
                                Icons.fullscreen_exit_rounded,
                                color: Colors.white,
                              )),
                        ),
                    ],
                  ),
      ),
    );
  }
}
