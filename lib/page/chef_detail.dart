import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/dummy_home.dart';
import 'dheskripsi.dart';

class ChefDetailPage extends StatefulWidget {
  final String chefName;
  final String chefImage;

  const ChefDetailPage({
    super.key,
    required this.chefName,
    required this.chefImage,
  });

  @override
  State<ChefDetailPage> createState() => _ChefDetailPageState();
}

class _ChefDetailPageState extends State<ChefDetailPage> {
  // ================= FETCH CHEF DATA =================
  Future<Map<String, dynamic>?> _fetchChef() async {
    final doc = await FirebaseFirestore.instance
        .collection('chefs')
        .doc(widget.chefName)
        .get();
    return doc.data();
  }

  // ================= FETCH RESEP CHEF =================
  Future<List<Recipe>> _fetchChefRecipes(List<String> recipeTitles) async {
    if (recipeTitles.isEmpty) return [];

    final snap = await FirebaseFirestore.instance
        .collection('recipes')
        .where('title', whereIn: recipeTitles)
        .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return Recipe(
        title: d['title'] ?? '',
        description: d['description'] ?? '',
        image: d['image'] ?? '',
        category: d['category'] ?? '',
        rating: (d['rating'] ?? 0).toDouble(),
        duration: d['duration'] ?? '',
        history: d['history'] ?? '',
        ingredients: List<String>.from(d['ingredients'] ?? []),
        steps: List<String>.from(d['steps'] ?? []),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchChef(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chef = snapshot.data;
          final bio = chef?['bio'] ?? '-';
          final specialty = chef?['specialty'] ?? '-';
          final recipeTitles = List<String>.from(chef?['recipes'] ?? []);

          return CustomScrollView(
            slivers: [
              // ================= SLIVER APP BAR =================
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.blue.shade600,
                leading: _circleBtn(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // GRADIENT BACKGROUND
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // FOTO CHEF
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundImage:
                                    widget.chefImage.startsWith('http')
                                    ? NetworkImage(widget.chefImage)
                                          as ImageProvider
                                    : AssetImage(widget.chefImage),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.chefName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                specialty,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= KONTEN =================
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // BIO
                      const Text(
                        'Tentang Chef',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bio,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // RESEP CHEF
                      const Text(
                        'Resep dari Chef ini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      FutureBuilder<List<Recipe>>(
                        future: _fetchChefRecipes(recipeTitles),
                        builder: (context, recipeSnap) {
                          if (recipeSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final recipes = recipeSnap.data ?? [];

                          if (recipes.isEmpty) {
                            return const Text(
                              'Belum ada resep',
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) => _recipeListTile(recipes[i]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= RECIPE TILE =================
  Widget _recipeListTile(Recipe recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // GAMBAR
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: _buildRecipeImage(recipe.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          recipe.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String img) {
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 85,
          height: 85,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    } else if (img.startsWith('data:image')) {
      return Image.memory(
        base64Decode(img.split(',').last),
        width: 85,
        height: 85,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        img,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 85,
          height: 85,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  // ================= HELPER WIDGETS =================
  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade200);
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withOpacity(0.2),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
