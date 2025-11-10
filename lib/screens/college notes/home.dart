import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/glass_container.dart';
import '../../widgets/custom_navigation.dart';
import 'pdf_screen.dart';

class BranchesGrid extends StatelessWidget {
  const BranchesGrid({super.key});

  Future<List<Map<String, dynamic>>> fetchBranches() async {
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
    CustomNavigation().navigateWithAd(ctx, PdfScreen(branch: branch));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchBranches(),
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: branches.length < 6 ? branches.length : 6,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => selectBranch(context, branches[index]),
              borderRadius: BorderRadius.circular(30),
              child: GlassContainer(
                color1: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.blue,
                color2: Theme.of(context).brightness == Brightness.dark
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
    );
  }
}
