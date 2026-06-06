import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../data/dummy_home.dart';
import '../page/dheskripsi.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _user = FirebaseAuth.instance.currentUser;

  Stream<List<Recipe>> _favoritesStream() {
    if (_user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
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
            }).toList());
  }

  Future<void> _removeFavorite(String title) async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(title)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Resep dihapus dari favorit'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (_searchQuery.isEmpty) return recipes;
    return recipes
        .where((r) =>
            r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ================= HELPER GAMBAR =================
  Widget _buildImage(String image,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade200,
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    } else if (image.startsWith('data:image')) {
      return Image.memory(
        base64Decode(image.split(',').last),
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      return Image.asset(
        image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: StreamBuilder<List<Recipe>>(
          stream: _favoritesStream(),
          builder: (context, snapshot) {
            final allFavorites = snapshot.data ?? [];
            final filtered = _filterRecipes(allFavorites);

            return Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade400
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Favorites',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${allFavorites.length} resep tersimpan',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),

                // ================= SEARCH BAR =================
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cari resep favorit...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  }),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ================= KONTEN =================
                Expanded(
                  child: snapshot.connectionState ==
                          ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : _user == null
                          ? _notLoggedIn()
                          : filtered.isEmpty
                              ? _emptyState()
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 16),
                                  itemCount: filtered.length,
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.78,
                                  ),
                                  itemBuilder: (_, i) =>
                                      _favoriteCard(filtered[i]),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _favoriteCard(Recipe recipe) {
    return Dismissible(
      key: Key(recipe.title),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFavorite(recipe.title),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipe: recipe)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: _buildImage(recipe.image,
                    width: double.infinity, height: 115),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(recipe.category,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 6),
                    Text(recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(recipe.rating.toString(),
                            style: const TextStyle(fontSize: 11)),
                        const Spacer(),
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(recipe.duration,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching
                ? Icons.search_off_rounded
                : Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'Resep tidak ditemukan'
                : 'Belum ada resep favorit',
            style:
                TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Tap ❤️ di detail resep untuk menyimpannya',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }

 Widget _notLoggedIn() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const Text('Login untuk melihat favorit',
            style: TextStyle(fontSize: 15, color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Login', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}