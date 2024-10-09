import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/glass_container.dart';
import 'playlists.dart';

class YoutubeGrid extends StatelessWidget {
  const YoutubeGrid({super.key});

  Future<List<Map<String, dynamic>>> fetchYoutubeTopics() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('youtube').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching YouTube channels: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchYoutubeTopics(),
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: youtubeTopics.length < 6 ? youtubeTopics.length : 6,
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
    );
  }
}
