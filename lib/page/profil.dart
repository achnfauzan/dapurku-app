import 'package:aplikasi_resep/data/dummy_home.dart';
import 'package:aplikasi_resep/page/dheskripsi.dart';
import 'package:aplikasi_resep/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    FirebaseAuth.instance.currentUser?.reload().then((_) {
      if (mounted) {
        setState(() {
          _user = FirebaseAuth.instance.currentUser;
        });
      }
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Kamu belum login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login untuk melihat profil dan resepmu',
                style: TextStyle(color: Colors.grey),
              ),
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
        ),
      );
    }

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
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _profileInfo(),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_resepTab(), _tentangTab(), _ulasanTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          const Text(
            'Profil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin mau logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) _logout();
            },
          ),
        ],
      ),
    );
  }

  // ================= PROFILE INFO =================
  Widget _profileInfo() {
    final email = _user?.email ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final photoBase64 = data?['photoBase64'];
        final photoUrl = _user?.photoURL;
        final displayName =
            data?['displayName'] ?? _user?.displayName ?? 'Pengguna';

        ImageProvider photo;
        if (photoBase64 != null) {
          photo = MemoryImage(base64Decode(photoBase64));
        } else if (photoUrl != null && photoUrl.startsWith('http')) {
          photo = CachedNetworkImageProvider(photoUrl);
        } else {
          photo = const AssetImage('assets/pp/default.jpg');
        }

        return Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(radius: 44, backgroundImage: photo),
            const SizedBox(height: 10),
            Text(
              displayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => AuthHelper.requireLogin(context, () async {
                await Navigator.pushNamed(context, '/edit_profil');
                setState(() {});
              }),
              child: const Text(
                'Edit Profil',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= TAB BAR =================
  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      tabs: const [
        Tab(text: 'Resep'),
        Tab(text: 'Tentang'),
        Tab(text: 'Ulasan'),
      ],
    );
  }

  // ================= RESEP TAB =================
  Widget _resepTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: _user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada resep',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                SizedBox(height: 4),
                Text('Tap tombol + untuk tambah resep',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final img = d['image'] ?? '';

            Widget buildImage() {
              if (img.startsWith('http')) {
                return CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                );
              } else if (img.startsWith('data:image')) {
                final base64Str = img.split(',').last;
                return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
              } else {
                return Image.asset(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                );
              }
            }

            return GestureDetector(
              onTap: () {
                final recipeData = docs[i].data() as Map<String, dynamic>;
                final recipe = Recipe(
                  title: recipeData['title'] ?? '',
                  description: recipeData['description'] ?? '',
                  image: recipeData['image'] ?? '',
                  category: recipeData['category'] ?? '',
                  duration: recipeData['duration'] ?? '',
                  history: recipeData['history'] ?? '',
                  rating: (recipeData['rating'] ?? 0).toDouble(),
                  ingredients:
                      List<String>.from(recipeData['ingredients'] ?? []),
                  steps: List<String>.from(recipeData['steps'] ?? []),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipe: recipe)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: buildImage(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(d['category'] ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text((d['rating'] ?? 0).toString(),
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              const Icon(Icons.schedule,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(d['duration'] ?? '',
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
      },
    );
  }

  // ================= TENTANG =================
  Widget _tentangTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final bio = data?['bio'] ?? '';
        return Padding(
          padding: const EdgeInsets.all(16),
          child: bio.isEmpty
              ? const Text(
                  'Belum ada bio. Tap Edit Profil untuk menambahkan.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
              : Text(bio, style: const TextStyle(fontSize: 14, height: 1.6)),
        );
      },
    );
  }

  // ================= ULASAN =================
  Widget _ulasanTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: _user?.uid)
          .get(),
      builder: (context, recipeSnap) {
        if (recipeSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipeDocs = recipeSnap.data?.docs ?? [];

        if (recipeDocs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review_outlined, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada resep yang bisa diulas',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          );
        }

        final recipeIds = recipeDocs.map((d) => d.id).toList();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchAllReviews(recipeIds, recipeDocs),
          builder: (context, reviewSnap) {
            if (reviewSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allReviews = reviewSnap.data ?? [];

            if (allReviews.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 56, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Belum ada ulasan untuk resepmu',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Bagikan resepmu agar orang lain bisa mengulas!',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }

            final avgRating = allReviews.fold<double>(
                    0, (s, r) => s + (r['rating'] as num).toDouble()) /
                allReviews.length;

            final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
            for (final r in allReviews) {
              final rating = (r['rating'] as num).toInt();
              dist[rating] = (dist[rating] ?? 0) + 1;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 42, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (i) {
                              if (i < avgRating.floor()) {
                                return const Icon(Icons.star,
                                    color: Colors.amber, size: 18);
                              } else if (i < avgRating) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 18);
                              }
                              return const Icon(Icons.star_border,
                                  color: Colors.amber, size: 18);
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text('${allReviews.length} ulasan',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((s) {
                            final count = dist[s] ?? 0;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text('$s'),
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: allReviews.isEmpty
                                            ? 0
                                            : count / allReviews.length,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$count'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...allReviews.map((r) {
                    final ts = r['createdAt'] as Timestamp?;
                    final time =
                        ts != null ? _timeAgo(ts.toDate()) : 'Baru saja';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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
                            child: Text(r['recipeTitle'] ?? '',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage:
                                    (r['userPhoto'] ?? '').isNotEmpty
                                        ? NetworkImage(r['userPhoto'])
                                        : null,
                                child: (r['userPhoto'] ?? '').isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white, size: 18)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(r['userName'] ?? 'Pengguna',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                        const Spacer(),
                                        Text(time,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < (r['rating'] as num).toInt()
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 13,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(r['comment'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                            height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= FETCH ALL REVIEWS =================
  Future<List<Map<String, dynamic>>> _fetchAllReviews(
    List<String> recipeIds,
    List<QueryDocumentSnapshot> recipeDocs,
  ) async {
    final List<Map<String, dynamic>> allReviews = [];
    for (final recipeDoc in recipeDocs) {
      final recipeData = recipeDoc.data() as Map<String, dynamic>;
      final recipeTitle = recipeData['title'] ?? '';
      final reviewsSnap = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeDoc.id)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();
      for (final review in reviewsSnap.docs) {
        final d = review.data();
        allReviews.add({...d, 'recipeTitle': recipeTitle});
      }
    }
    allReviews.sort((a, b) {
      final aTs = a['createdAt'] as Timestamp?;
      final bTs = b['createdAt'] as Timestamp?;
      if (aTs == null || bTs == null) return 0;
      return bTs.compareTo(aTs);
    });
    return allReviews;
  }

  // ================= TIME AGO =================
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