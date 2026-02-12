import 'package:flutter/material.dart';
import '../data/dummy_home.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isLoved = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          /// ================= SCROLL CONTENT =================
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  recipe.image,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// CHEF
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage(topChefs[0].values.last),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topChefs[0].values.first,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const Text(
                                'Chef Profesional',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// INFO
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

                      /// DESKRIPSI
                      _sectionTitle('Deskripsi'),
                      const SizedBox(height: 12),
                      Text(
                        recipe.description,
                        style:
                            const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 32),

                      /// BAHAN
                      _sectionTitle('Bahan'),
                      const SizedBox(height: 12),
                      ...recipe.ingredients
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6),
                                child: Text('• $e'),
                              ))
                          .toList(),

                      const SizedBox(height: 32),

                      /// CARA MEMASAK
                      _sectionTitle('Cara Memasak'),
                      const SizedBox(height: 12),
                      ...recipe.steps.asMap().entries.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e.key + 1}. ',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  Expanded(child: Text(e.value)),
                                ],
                              ),
                            ),
                          ),

                      const SizedBox(height: 36),

                      /// ULASAN
                      Row(
                        children: [
                          _sectionTitle('Ulasan'),
                          const Spacer(),
                          const Icon(Icons.add),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: const [
                              Text(
                                '4.8',
                                style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 16,
                                      color: Colors.amber),
                                  Icon(Icons.star,
                                      size: 16,
                                      color: Colors.amber),
                                  Icon(Icons.star,
                                      size: 16,
                                      color: Colors.amber),
                                  Icon(Icons.star,
                                      size: 16,
                                      color: Colors.amber),
                                  Icon(Icons.star_half,
                                      size: 16,
                                      color: Colors.amber),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '128 ulasan',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                _ratingBar(5, 0.7),
                                const SizedBox(height: 6),
                                _ratingBar(4, 0.2),
                                const SizedBox(height: 6),
                                _ratingBar(3, 0.07),
                                const SizedBox(height: 6),
                                _ratingBar(2, 0.02),
                                const SizedBox(height: 6),
                                _ratingBar(1, 0.01),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      _commentTile(
                        name: 'Embun Subroto',
                        time: '4 hari lalu',
                        text:
                            'Resepnya jelas dan rasanya enak, recommended!',
                        rating: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// FIXED BUTTON
          Positioned(
            top: 40,
            left: 16,
            child: _circleBtn(
              Icons.arrow_back,
              () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                _circleBtn(
                  isLoved
                      ? Icons.favorite
                      : Icons.favorite_border,
                  () => setState(() => isLoved = !isLoved),
                  color: isLoved ? Colors.red : Colors.black,
                ),
                const SizedBox(width: 10),
                _circleBtn(Icons.share, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= COMPONENT =================

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600),
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.w600)),
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
    required String time,
    required String text,
    required int rating,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/200'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$name\n$time',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Row(
              children: List.generate(
                rating,
                (_) => const Icon(Icons.star,
                    size: 14,
                    color: Colors.amber),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style:
              const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
