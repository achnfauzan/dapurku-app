import 'package:cloud_firestore/cloud_firestore.dart';
import 'dummy_home.dart';

Future<void> seedRecipes() async {
  final col = FirebaseFirestore.instance.collection('recipes');
  final snapshot = await col.limit(1).get();
  if (snapshot.docs.isNotEmpty) return;

  for (final r in popularRecipes) {
    await col.add({
      'title': r.title,
      'description': r.description,
      'image': r.image,
      'category': r.category,
      'rating': r.rating,
      'duration': r.duration,
      'history': r.history,
      'ingredients': r.ingredients,
      'steps': r.steps,
    });
  }
}


Future<void> seedChefs() async {
  final chefs = FirebaseFirestore.instance.collection('chefs');
  final snapshot = await chefs.limit(1).get();
  if (snapshot.docs.isNotEmpty) return;

  final List<Map<String, dynamic>> chefData = [
    {
      'name': 'Chef Arif',
      'image': 'assets/pp/c1.jpg',
      'bio': 'Chef Arif adalah koki berpengalaman dengan spesialisasi masakan tradisional Jawa. Lebih dari 10 tahun menggeluti dunia kuliner.',
      'specialty': 'Masakan Tradisional',
      'recipes': ['Rawon', 'Sate Sapi'],
    },
    {
      'name': 'Chef Dinda',
      'image': 'assets/pp/c2.jpg',
      'bio': 'Chef Dinda dikenal dengan kreasi sarapan sehatnya yang lezat dan mudah dibuat.',
      'specialty': 'Sarapan & Healthy Food',
      'recipes': ['Nasi Goreng', 'Nasi Uduk'],
    },
    {
      'name': 'Chef Raka',
      'image': 'assets/pp/c3.jpg',
      'bio': 'Chef Raka spesialis masakan pedas dan grilled food. Pemenang berbagai kompetisi memasak tingkat nasional.',
      'specialty': 'Masakan Pedas & Bakar',
      'recipes': ['Ayam Geprek', 'Sate Sapi'],
    },
    {
      'name': 'Chef Sinta',
      'image': 'assets/pp/c4.jpg',
      'bio': 'Chef Sinta ahli dalam minuman dan dessert tradisional Indonesia.',
      'specialty': 'Minuman & Dessert',
      'recipes': ['Es Buah', 'STMJ'],
    },
    {
      'name': 'Chef Bayu',
      'image': 'assets/pp/c5.jpg',
      'bio': 'Chef Bayu berfokus pada masakan rumahan yang simpel namun kaya rasa.',
      'specialty': 'Masakan Rumahan',
      'recipes': ['Ayam Kecap', 'Bakso'],
    },
  ];

  for (final chef in chefData) {
    await chefs.doc(chef['name']).set(chef);
  }
}