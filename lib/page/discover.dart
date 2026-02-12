import 'package:flutter/material.dart';
import '../data/dummy_home.dart'; // topChefs, popularRecipes, initialTags, additionalTags
import '../page/dheskripsi.dart'; // RecipeDetailPage

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String selectedCategory = 'All';
  bool showAllTags = false;
  bool showAllRecipes = false;

  List<String> get currentTags =>
      showAllTags ? [...initialTags, ...additionalTags] : initialTags;

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = selectedCategory == 'All'
        ? popularRecipes
        : popularRecipes
            .where((r) => r.category == selectedCategory)
            .toList();

    final displayedRecipes =
        showAllRecipes ? filteredRecipes : filteredRecipes.take(6).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _discoverHeader(),

            // 🔥 GAP DARI SEARCH BAR KE TRENDING
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Trending Now'),
                  const SizedBox(height: 12),
                  _trendingRecipes(),
                  const SizedBox(height: 24),

                  // CATEGORY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('Explore by Category'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showAllTags = !showAllTags;
                          });
                        },
                        child: Text(showAllTags ? 'Collapse' : 'See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _categoryTags(currentTags),
                  const SizedBox(height: 16),

                  // GRID RESULT
                  _recipeGrid(displayedRecipes),

                  if (filteredRecipes.length > 6)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllRecipes = !showAllRecipes;
                          });
                        },
                        child: Text(
                          showAllRecipes
                              ? 'Show Less'
                              : 'See ${filteredRecipes.length - 6} more',
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  _sectionTitle('Top Chefs'),
                  const SizedBox(height: 12),
                  _topChefList(),
                  const SizedBox(height: 24),
                  _sectionTitle('Popular Recipes'),
                  const SizedBox(height: 12),
                  _popularRecipesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _discoverHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // BACKGROUND BIRU
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 70),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Discover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Find recipes you love',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        // SEARCH BAR (OFFSET SETENGAH BIRU - PUTIH)
        Positioned(
          left: 16,
          right: 16,
          bottom: -26,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  // ================= TRENDING =================
  Widget _trendingRecipes() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (_, index) {
          final recipe = popularRecipes[index];
          return GestureDetector(
            onTap: () => _openDetail(recipe),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: recipe.image.startsWith('http')
                      ? NetworkImage(recipe.image)
                      : AssetImage(recipe.image) as ImageProvider,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
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

  // ================= TAG =================
  Widget _categoryTags(List<String> tags) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags.map((category) {
        final isActive = selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = category;
              showAllRecipes = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= GRID =================
  Widget _recipeGrid(List recipes) {
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No recipes found')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1,
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: recipe.image.startsWith('http')
                        ? Image.network(recipe.image,
                            width: double.infinity, fit: BoxFit.cover)
                        : Image.asset(recipe.image,
                            width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.category,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(recipe.rating.toString(),
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            recipe.duration,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
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
      },
    );
  }

  // ================= TOP CHEF =================
  Widget _topChefList() {
    return SizedBox(
      height: 100,
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
                  radius: 32,
                  backgroundImage: AssetImage(chef['image']!),
                ),
                const SizedBox(height: 6),
                Text(chef['name']!,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= POPULAR =================
  Widget _popularRecipesSection() {
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
                image: recipe.image.startsWith('http')
                    ? NetworkImage(recipe.image)
                    : AssetImage(recipe.image) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
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
                      const Icon(Icons.star,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
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

  void _openDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }
}
