import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'Sate Ayam',
      'rating': 4.8,
      'time': '25 menit',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _profileInfo(),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _resepTab(),
                  _tentangTab(),
                  _ulasanTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          'Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ================= PROFILE INFO =================
  Widget _profileInfo() {
    return Column(
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 44,
          backgroundImage: const AssetImage(
            '../assets/pp/c6.jpg',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Farid Pratama',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Food Creator',
          style: TextStyle(color: Colors.grey),
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
          onPressed: () {},
          child: const Text(
            'Edit Profil',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // ================= TAB BAR =================
  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      tabs: [
        Tab(text: 'Resep (${recipes.length})'),
        const Tab(text: 'Tentang'),
        const Tab(text: 'Ulasan'),
      ],
    );
  }

  // ================= RESEP TAB =================
Widget _resepTab() {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: recipes.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.85, // ⬅️ bikin card tidak kepanjangan
    ),
    itemBuilder: (context, i) {
      final recipe = recipes[i];

      return Container(
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
            // ===== IMAGE =====
            SizedBox(
              height: 110,
              width: double.infinity,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  '../assets/sate2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ===== INFO =====
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Makanan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recipe['rating'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        recipe['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  // ================= TENTANG =================
  Widget _tentangTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Kami adalah kreator resep yang berfokus pada '
        'masakan rumahan sederhana, lezat, dan mudah '
        'dipraktikkan oleh siapa saja.',
        style: TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }

  // ================= ULASAN =================
  Widget _ulasanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: const [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star_half,
                          color: Colors.amber, size: 18),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '120 ulasan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _ratingBar(5, 80),
                    _ratingBar(4, 25),
                    _ratingBar(3, 10),
                    _ratingBar(2, 3),
                    _ratingBar(1, 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('Tambah Ulasan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 24),
          _reviewCard(
            name: 'Andi',
            rating: 5,
            comment: 'Resepnya jelas, mudah diikuti, dan rasanya enak.',
          ),
          _reviewCard(
            name: 'Salsa',
            rating: 4,
            comment: 'Tampilan aplikasinya bersih dan nyaman dipakai.',
          ),
        ],
      ),
    );
  }

  Widget _ratingBar(int star, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$star'),
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: count / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(count.toString()),
        ],
      ),
    );
  }

  Widget _reviewCard({
    required String name,
    required int rating,
    required String comment,
  }) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                const AssetImage('assets/images/profile.jpg'),
          ),
          const SizedBox(width: 12),
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
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        rating,
                        (_) => const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
