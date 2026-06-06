import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../data/dummy_home.dart';
import '../page/dheskripsi.dart';
import '../page/chef_detail.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedCategory = 'All';
  bool showAllTags = false;
  bool showAllRecipes = false;

  final List<String> initialTags = [
    'All', 'Sarapan', 'Makan Siang', 'Makan Malam',
  ];
  final List<String> additionalTags = ['Camilan', 'Minuman', 'Tradisional'];

  List<String> get currentTags =>
      showAllTags ? [...initialTags, ...additionalTags] : initialTags;

  Stream<List<Recipe>> _recipeStream() {
    return FirebaseFirestore.instance
        .collection('recipes')
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

  List<Recipe> _filterRecipes(List<Recipe> all) {
    return all.where((r) {
      final matchCategory = selectedCategory == 'All' ||
          r.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void _openDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
    );
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
    return StreamBuilder<List<Recipe>>(
      stream: _recipeStream(),
      builder: (context, snapshot) {
        final allRecipes = snapshot.data ?? popularRecipes;
        final filtered = _filterRecipes(allRecipes);
        final displayed =
            showAllRecipes ? filtered : filtered.take(6).toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _discoverHeader(),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchQuery.isNotEmpty) ...[
                        Row(
                          children: [
                            _sectionTitle('Hasil Pencarian'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${filtered.length} resep',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (filtered.isEmpty)
                          _emptyState()
                        else
                          _recipeGrid(displayed),
                        if (filtered.length > 6)
                          _showMoreButton(filtered.length),
                      ] else ...[
                        _sectionTitle('Sedang Trending'),
                        const SizedBox(height: 12),
                        snapshot.connectionState == ConnectionState.waiting
                            ? _shimmerTrending()
                            : _trendingRecipes(allRecipes),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionTitle('Jelajahi Kategori'),
                            TextButton(
                              onPressed: () => setState(
                                  () => showAllTags = !showAllTags),
                              child: Text(
                                  showAllTags ? 'Urungkan' : 'Lihat Semua'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _categoryTags(currentTags),
                        const SizedBox(height: 16),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          _shimmerGrid()
                        else if (filtered.isEmpty)
                          _emptyState()
                        else
                          _recipeGrid(displayed),
                        if (filtered.length > 6)
                          _showMoreButton(filtered.length),
                        const SizedBox(height: 24),
                        _sectionTitle('Chef Teratas'),
                        const SizedBox(height: 12),
                        _topChefList(),
                        const SizedBox(height: 24),
                        _sectionTitle('chef Populer'),
                        const SizedBox(height: 12),
                        _popularRecipesSection(allRecipes),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _discoverHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 70),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pencarian',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Temukan Resep Favoritmu',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -26,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {
                _searchQuery = val;
                showAllRecipes = false;
              }),
              decoration: InputDecoration(
                hintText: 'Cari resep...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );

  Widget _trendingRecipes(List<Recipe> recipes) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (_, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () => _openDetail(recipe),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(recipe.image),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(recipe.rating.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
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
        },
      ),
    );
  }

  Widget _categoryTags(List<String> tags) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags.map((cat) {
        final isActive = selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() {
            selectedCategory = cat;
            showAllRecipes = false;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade600 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                  : [],
            ),
            child: Text(cat,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color:
                        isActive ? Colors.white : Colors.black87)),
          ),
        );
      }).toList(),
    );
  }

  Widget _recipeGrid(List<Recipe> recipes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) {
        final recipe = recipes[i];
        return GestureDetector(
          onTap: () => _openDetail(recipe),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: _buildImage(recipe.image,
                      height: 120, width: double.infinity),
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
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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
        );
      },
    );
  }

  Widget _showMoreButton(int total) {
    return Center(
      child: TextButton(
        onPressed: () =>
            setState(() => showAllRecipes = !showAllRecipes),
        child: Text(
            showAllRecipes ? 'Tampilkan Lebih Sedikit' : 'Lihat ${total - 6} lainnya'),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Resep tidak ditemukan',
                style:
                    TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerTrending() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 220,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _topChefList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topChefs.length,
        itemBuilder: (_, i) {
          final chef = topChefs[i];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChefDetailPage(
                    chefName: chef['name']!,
                    chefImage: chef['image']!,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage(chef['image']!),
                  ),
                  const SizedBox(height: 8),
                  Text(chef['name']!,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _popularRecipesSection(List<Recipe> recipes) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (_, i) {
          final recipe = recipes[i];
          return GestureDetector(
            onTap: () => _openDetail(recipe),
            child: Container(
              width: 210,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(recipe.image),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(recipe.rating.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
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
        },
      ),
    );
  }
}