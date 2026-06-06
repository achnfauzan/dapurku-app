import 'package:aplikasi_resep/page/recently_viewed.dart';
import 'package:aplikasi_resep/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../data/dummy_home.dart';
import 'dheskripsi.dart';
import 'chef_detail.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool notifActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final User? _user = FirebaseAuth.instance.currentUser;

  Stream<List<Recipe>> _recipeStream() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
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
          }).toList(),
        );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (_searchQuery.isEmpty) return recipes;
    return recipes
        .where(
          (r) =>
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // ================= HELPER GAMBAR =================
  Widget _buildImage(
    String image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

  Widget _recipeImage({
    required String image,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final child = _buildImage(image, width: width, height: height, fit: fit);
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipe>>(
      stream: _recipeStream(),
      builder: (context, snapshot) {
        final allRecipes = snapshot.data ?? popularRecipes;
        final recipes = _filterRecipes(allRecipes);

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          floatingActionButton: FloatingActionButton(
            onPressed: () => AuthHelper.requireLogin(
              context,
              () => Navigator.pushNamed(context, '/tambah_resep'),
            ),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _header(),
                if (_searchQuery.isNotEmpty && recipes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Resep tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchQuery.isEmpty) ...[
                          _motivasiCard(),
                          const SizedBox(height: 28),
                          _sectionTitle('Kategori'),
                          const SizedBox(height: 12),
                          _categoryList(),
                          const SizedBox(height: 28),
                          _sectionTitle('Resep Populer'),
                          const SizedBox(height: 12),
                          _popularCard(recipes),
                          const SizedBox(height: 28),
                          _sectionTitle('Chef Teratas'),
                          const SizedBox(height: 12),
                          _topChefList(),
                          const SizedBox(height: 28),
                          _sectionTitle('Recommendasi Untuk Anda'),
                          const SizedBox(height: 12),
                          _recommendationCards(recipes),
                          const SizedBox(height: 28),
                          _sectionTitle('Pilihan Hari ini'),
                          const SizedBox(height: 12),
                          _menuHariIni(recipes),
                          const SizedBox(height: 28),
                          _sectionTitle('Terakhir Dilihat'),
                          const SizedBox(height: 12),
                          _recentViewed(recipes),
                          const SizedBox(height: 28),
                          _tipsCard(),
                        ] else ...[
                          _sectionTitle('Hasil Pencarian (${recipes.length})'),
                          const SizedBox(height: 12),
                          _searchResults(recipes),
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

  // ================= HEADER =================
  Widget _header() {
    final displayName = _user?.displayName ?? 'Pengguna';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid)
          .snapshots(),
      builder: (context, userSnap) {
        final data = userSnap.data?.data() as Map<String, dynamic>?;
        final photoBase64 = data?['photoBase64'];
        final photoUrl = _user?.photoURL;

        ImageProvider photo;
        if (photoBase64 != null) {
          photo = MemoryImage(base64Decode(photoBase64));
        } else if (photoUrl != null && photoUrl.startsWith('http')) {
          photo = CachedNetworkImageProvider(photoUrl);
        } else {
          photo = const AssetImage('assets/pp/default.jpg');
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 22, backgroundImage: photo),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $displayName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Masak enak hari ini',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: notifActive ? Colors.blue[900] : Colors.white,
                    ),
                    onPressed: () => setState(() => notifActive = !notifActive),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari resep favoritmu...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
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
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingPage()),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.settings, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SEARCH RESULTS =================
  Widget _searchResults(List<Recipe> recipes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (_, i) {
        final r = recipes[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: r)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                _recipeImage(
                  image: r.image,
                  width: 90,
                  height: 90,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.category,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              r.rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              r.duration,
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
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= MOTIVASI =================
  Widget _motivasiCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.blue.withOpacity(0.45),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masak dengan Tujuan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Masakan terbaik lahir dari niat yang baik, bukan dari bahan yang mahal.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  // ================= CATEGORY =================
  Widget _categoryList() {
    final categories = [
      'Sarapan',
      'Makan Siang',
      'Makan Malam',
      'Camilan',
      'Minuman',
      'Tradisional',
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() {
            _searchQuery = categories[i];
            _searchController.text = categories[i];
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              categories[i],
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= POPULAR =================
  Widget _popularCard(List<Recipe> recipes) {
    if (recipes.isEmpty) return const SizedBox();
    final recipe = recipes.first;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            _buildImage(recipe.image, width: double.infinity, height: 230),
            Container(
              height: 230,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(14),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.rating} • ${recipe.duration}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP CHEF =================
  Widget _topChefList() {
    return SizedBox(
      height: 150,
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
                    radius: 42,
                    backgroundImage: AssetImage(chef['image']!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chef['name']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= REKOMENDASI =================
  Widget _recommendationCards(List<Recipe> recipes) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (_, i) {
          final recipe = recipes[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailPage(recipe: recipe),
              ),
            ),
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    _buildImage(recipe.image, width: 260, height: 180),
                    Container(
                      width: 260,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipe.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
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

  // ================= MENU HARI INI =================
  Widget _menuHariIni(List<Recipe> recipes) {
    if (recipes.length < 4) return const SizedBox();
    final recipe = recipes[3];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            _recipeImage(
              image: recipe.image,
              width: 120,
              height: 120,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pilihan Hari Ini',
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.duration,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentViewed(List<Recipe> allRecipes) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.value(RecentlyViewedHelper.get()),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Text(
            'Belum ada resep yang dilihat',
            style: TextStyle(color: Colors.grey),
          );
        }

        final recentRecipes = items
            .map((item) {
              final title = item['title'] as String;
              final viewedAt = item['viewedAt'] as String;
              final recipe = allRecipes.firstWhere(
                (r) => r.title == title,
                orElse: () => Recipe(
                  title: '',
                  description: '',
                  image: '',
                  category: '',
                  rating: 0,
                  duration: '',
                  history: '',
                  ingredients: [],
                  steps: [],
                ),
              );
              return {'recipe': recipe, 'viewedAt': viewedAt};
            })
            .where((e) => (e['recipe'] as Recipe).title.isNotEmpty)
            .toList();

        if (recentRecipes.isEmpty) return const SizedBox();

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentRecipes.length,
            itemBuilder: (_, i) {
              final recipe = recentRecipes[i]['recipe'] as Recipe;
              final viewedAt = recentRecipes[i]['viewedAt'] as String;
              final timeText = RecentlyViewedHelper.timeAgo(viewedAt);

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailPage(recipe: recipe),
                  ),
                ),
                child: Container(
                  width: 210,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        _buildImage(recipe.image, width: 210, height: 150),
                        Container(
                          width: 210,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                recipe.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.access_time,
                                    size: 11,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeText, // ← pakai waktu dilihat
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
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
      },
    );
  }

  // ================= TIPS =================
  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Diamkan daging setelah dibumbui agar rasa lebih meresap sempurna.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
