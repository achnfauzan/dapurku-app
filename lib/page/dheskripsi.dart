import 'package:aplikasi_resep/page/recently_viewed.dart';
import 'package:aplikasi_resep/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../data/dummy_home.dart';
import 'edit_resep.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isLoved = false;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    RecentlyViewedHelper.add(widget.recipe.title);
  }

  Future<void> _checkFavorite() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(widget.recipe.title)
        .get();
    setState(() => isLoved = doc.exists);
  }

  Future<void> _toggleFavorite() async {
    if (_user == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(widget.recipe.title);

    if (isLoved) {
      await ref.delete();
    } else {
      await ref.set({
        'title': widget.recipe.title,
        'image': widget.recipe.image,
        'category': widget.recipe.category,
        'rating': widget.recipe.rating,
        'duration': widget.recipe.duration,
        'description': widget.recipe.description,
        'history': widget.recipe.history,
        'ingredients': widget.recipe.ingredients,
        'steps': widget.recipe.steps,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() => isLoved = !isLoved);
  }

  Future<String?> _getRecipeDocId() async {
    final snap = await FirebaseFirestore.instance
        .collection('recipes')
        .where('title', isEqualTo: widget.recipe.title)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Stream<QuerySnapshot> _reviewsStream(String recipeId) {
    return FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  double _avgRating(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0;
    final total = docs.fold<double>(
      0,
      (sum, d) => sum + (d['rating'] as num).toDouble(),
    );
    return total / docs.length;
  }

  Map<int, double> _ratingDistribution(List<QueryDocumentSnapshot> docs) {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final d in docs) {
      final r = (d['rating'] as num).toInt();
      map[r] = (map[r] ?? 0) + 1;
    }
    return map.map((k, v) => MapEntry(k, docs.isEmpty ? 0.0 : v / docs.length));
  }

  void _showReviewSheet(String recipeId) {
    int selectedRating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tulis Ulasan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                widget.recipe.title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rating kamu:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRating = i + 1),
                    child: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Komentar:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Bagaimana pendapatmu tentang resep ini?',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedRating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih rating dulu!'),
                              ),
                            );
                            return;
                          }
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tulis komentar dulu!'),
                              ),
                            );
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(recipeId)
                                .collection('reviews')
                                .add({
                                  'uid': _user?.uid,
                                  'userName': _user?.displayName ?? 'Pengguna',
                                  'userPhoto': _user?.photoURL ?? '',
                                  'rating': selectedRating,
                                  'comment': commentController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            final reviewsSnap = await FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(recipeId)
                                .collection('reviews')
                                .get();
                            final avg =
                                reviewsSnap.docs.fold<double>(
                                  0,
                                  (s, d) => s + (d['rating'] as num).toDouble(),
                                ) /
                                reviewsSnap.docs.length;
                            await FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(recipeId)
                                .update({
                                  'rating': double.parse(
                                    avg.toStringAsFixed(1),
                                  ),
                                });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Ulasan berhasil dikirim! ⭐',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal kirim: $e')),
                            );
                          } finally {
                            setModalState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kirim Ulasan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final image = widget.recipe.image;
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 260,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 260,
          color: Colors.grey.shade300,
          child: const Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    } else if (image.startsWith('data:image')) {
      final base64Str = image.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      image,
      height: 260,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 260,
        color: Colors.grey.shade300,
        child: const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<String?>(
        future: _getRecipeDocId(),
        builder: (context, idSnap) {
          final recipeId = idSnap.data;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    Container(
                      transform: Matrix4.translationValues(0, -20, 0),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // JUDUL
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // CHEF
                          FutureBuilder<DocumentSnapshot?>(
                            future: recipeId != null
                                ? FirebaseFirestore.instance
                                      .collection('recipes')
                                      .doc(recipeId)
                                      .get()
                                : Future.value(null),
                            builder: (context, snap) {
                              final data =
                                  snap.data?.data() as Map<String, dynamic>?;
                              final authorName = data?['authorName'] ?? '';
                              final authorImage = data?['authorImage'] ?? '';

                              ImageProvider avatarImage;
                              if (authorImage.startsWith('data:image')) {
                                avatarImage = MemoryImage(
                                  base64Decode(authorImage.split(',').last),
                                );
                              } else if (authorImage.startsWith('http')) {
                                avatarImage = NetworkImage(authorImage);
                              } else {
                                avatarImage = AssetImage(
                                  authorImage.isNotEmpty
                                      ? authorImage
                                      : 'assets/pp/default.jpg',
                                );
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: avatarImage,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Text(
                                        'Chef Profesional',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // INFO CARD
                          Row(
                            children: [
                              _infoCard(
                                icon: Icons.schedule,
                                title: 'Waktu',
                                value: recipe.duration,
                              ),
                              const SizedBox(width: 12),
                              _infoCard(
                                icon: Icons.restaurant_menu,
                                title: 'Kategori',
                                value: recipe.category,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // DESKRIPSI
                          _sectionTitle('Deskripsi'),
                          const SizedBox(height: 12),
                          Text(
                            recipe.description,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 32),

                          // BAHAN
                          _sectionTitle('Bahan'),
                          const SizedBox(height: 12),
                          ...recipe.ingredients.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• $e'),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // CARA MEMASAK
                          _sectionTitle('Cara Memasak'),
                          const SizedBox(height: 12),
                          ...recipe.steps.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e.key + 1}. ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(child: Text(e.value)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ===== ULASAN =====
                          if (recipeId == null)
                            const SizedBox()
                          else
                            StreamBuilder<QuerySnapshot>(
                              stream: _reviewsStream(recipeId),
                              builder: (context, snap) {
                                final docs = snap.data?.docs ?? [];
                                final avg = _avgRating(docs);
                                final dist = _ratingDistribution(docs);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _sectionTitle('Ulasan'),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () => AuthHelper.requireLogin(
                                            context,
                                            () => _showReviewSheet(recipeId),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 14,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Tulis Ulasan',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // RATING SUMMARY
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              avg == 0
                                                  ? '0.0'
                                                  : avg.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(5, (i) {
                                                if (i < avg.floor()) {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  );
                                                } else if (i < avg) {
                                                  return const Icon(
                                                    Icons.star_half,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  );
                                                }
                                                return const Icon(
                                                  Icons.star_border,
                                                  size: 16,
                                                  color: Colors.amber,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${docs.length} ulasan',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            children: [5, 4, 3, 2, 1]
                                                .map(
                                                  (s) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 6,
                                                        ),
                                                    child: _ratingBar(
                                                      s,
                                                      dist[s] ?? 0,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // LIST KOMENTAR
                                    if (docs.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 40,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Belum ada ulasan, jadilah yang pertama!',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: docs.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 24),
                                        itemBuilder: (_, i) {
                                          final d =
                                              docs[i].data()
                                                  as Map<String, dynamic>;
                                          final ts =
                                              d['createdAt'] as Timestamp?;
                                          final time = ts != null
                                              ? _timeAgo(ts.toDate())
                                              : 'Baru saja';
                                          return _commentTile(
                                            name: d['userName'] ?? 'Pengguna',
                                            photoUrl: d['userPhoto'] ?? '',
                                            time: time,
                                            text: d['comment'] ?? '',
                                            rating: (d['rating'] as num)
                                                .toInt(),
                                          );
                                        },
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BACK BUTTON
              Positioned(
                top: 40,
                left: 16,
                child: _circleBtn(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
              ),

              // FAVORITE, SHARE & EDIT
              Positioned(
                top: 40,
                right: 16,
                child: FutureBuilder<DocumentSnapshot?>(
                  future: recipeId != null
                      ? FirebaseFirestore.instance
                            .collection('recipes')
                            .doc(recipeId)
                            .get()
                      : Future.value(null),
                  builder: (context, docSnap) {
                    final data = docSnap.data?.data() as Map<String, dynamic>?;
                    final isAuthor =
                        data != null && data['authorId'] == _user?.uid;

                    return Row(
                      children: [
                        // EDIT
                        if (isAuthor && recipeId != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _circleBtn(
                              Icons.edit_outlined,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditResepPage(
                                    recipeId: recipeId!,
                                    recipeData: data!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // FAVORIT
                        _circleBtn(
                          isLoved ? Icons.favorite : Icons.favorite_border,
                          () => AuthHelper.requireLogin(
                            context,
                            () => _toggleFavorite(),
                          ),
                          color: isLoved ? Colors.red : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        // SHARE
                        _circleBtn(Icons.share, () {
                          Share.share(
                            '🍽️ Coba resep "${recipe.title}"!\n\n'
                            '📂 Kategori: ${recipe.category}\n'
                            '⏱️ Durasi: ${recipe.duration}\n'
                            '⭐ Rating: ${recipe.rating}\n\n'
                            '📝 ${recipe.description}\n\n'
                            'Dibagikan dari Aplikasi Resep Makanan 🍴',
                            subject: recipe.title,
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingBar(int star, double value) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text('$star')),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _commentTile({
    required String name,
    required String photoUrl,
    required String time,
    required String text,
    required int rating,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : const AssetImage('assets/pp/default.jpg') as ImageProvider,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 13,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }
}
