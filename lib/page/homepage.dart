import 'package:flutter/material.dart';
import '../data/dummy_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool notifActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _motivasiCard(),
                  const SizedBox(height: 28),

                  _sectionTitle('Category'),
                  const SizedBox(height: 12),
                  _categoryList(),
                  const SizedBox(height: 28),

                  _sectionTitle('Popular Recipes'),
                  const SizedBox(height: 12),
                  _popularCard(),
                  const SizedBox(height: 28),

                  _sectionTitle('Top Chefs'),
                  const SizedBox(height: 12),
                  _topChefList(),
                  const SizedBox(height: 28),

                  _sectionTitle('Recommended For You'),
                  const SizedBox(height: 12),
                  _recommendationCards(),
                  const SizedBox(height: 28),

                  _sectionTitle('Today’s Pick'),
                  const SizedBox(height: 12),
                  _menuHariIni(),
                  const SizedBox(height: 28),

                  _sectionTitle('Recently Viewed'),
                  const SizedBox(height: 12),
                  _recentViewed(),
                  const SizedBox(height: 28),

                  _tipsCard(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
          ],
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
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('../assets/pp/c6.jpg'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Halo, Farid 👋',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Masak enak hari ini',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),

              // NOTIF
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: notifActive ? Colors.blue[900] : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    notifActive = !notifActive;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari resep favoritmu...',
                    prefixIcon: const Icon(Icons.search),
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

              // SETTING
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingPage(),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.settings, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
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

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

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
      itemBuilder: (_, i) {
        return Container(
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
        );
      },
    ),
  );
}

  // ================= POPULAR =================
  Widget _popularCard() {
    final recipe = popularRecipes.first;

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(recipe.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.rating} • ${recipe.duration}',
                    style: const TextStyle(
                        color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
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
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage:
                      NetworkImage(chef['image']!),
                ),
                const SizedBox(height: 8),
                Text(
                  chef['name']!,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= REKOMENDASI =================
  Widget _recommendationCards() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (_, i) {
          final recipe = popularRecipes[i];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: NetworkImage(recipe.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14,
                            color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12),
                        ),
                      ],
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
  Widget _menuHariIni() {
    final recipe = popularRecipes[3];

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: Image.network(
                recipe.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pilihan Hari Ini',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14,
                            color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(recipe.rating.toString(),
                            style: const TextStyle(
                                fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time,
                            size: 13,
                            color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(recipe.duration,
                            style: const TextStyle(
                                fontSize: 12)),
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

  // ================= RECENT =================
  Widget _recentViewed() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (_, i) {
          final recipe = popularRecipes[i];
          return Container(
            width: 210,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(recipe.image),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 12,
                          color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(recipe.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11)),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 11,
                          color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        '1 menit lalu',
                        style: TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline,
              color: Colors.blue),
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

// ================= SETTING PAGE =================
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  static const Color primaryBlue = Color(0xFF2563EB); // biru kalem

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // TODO: hapus session / token

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? primaryBlue),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          _sectionTitle('Aplikasi'),

          _item(
            icon: Icons.language,
            title: 'Bahasa',
            subtitle: 'Indonesia',
            onTap: () {},
          ),

          _item(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {},
          ),

          _item(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            onTap: () {},
          ),

          _sectionTitle('Bantuan'),

          _item(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            onTap: () {},
          ),

          _item(
            icon: Icons.mail_outline,
            title: 'Hubungi Kami',
            onTap: () {},
          ),

          const Divider(height: 32),

          /// Logout — tetap menyatu tapi jelas
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}
