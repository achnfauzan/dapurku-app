// ================= MODEL =================
class Recipe {
  final String title;
  final String description;
  final String image;
  final String category;
  final double rating;
  final String history;
  final String duration;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    required this.rating,
    required this.duration,
    required this.ingredients,
    required this.steps,
    required this.history,
  });
}
 List<Map<String, String>> topChefs = [
  {
    'name': 'Chef Arif',
    'image': '../assets/pp/c1.jpg',
  },
  {
    'name': 'Chef Dinda',
    'image': '../assets/pp/c2.jpg',
  },
  {
    'name': 'Chef Raka',
    'image': '../assets/pp/c3.jpg',
  },
  {
    'name': 'Chef Sinta',
    'image': '../assets/pp/c4.jpg',
  },
  {
    'name': 'Chef Bayu',
    'image': '../assets/pp/c5.jpg',
  },
];


// ================= DUMMY DATA =================
final List<Recipe> popularRecipes = [
  Recipe(
    title: 'Sate Sapi',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry',
    image: 'assets/sateSapi.jpg',
    category: 'Makan Malam',
    rating: 4.5,
    duration: '30 mnt',
    history: '2 menit yang lalu',
    ingredients: [
      '500 gram daging sapi',
      'Tusuk sate',
      'Kecap manis',
      'Bawang merah',
    ],
    steps: [
      'Potong daging sapi kecil-kecil',
      'Tusuk daging ke tusuk sate',
      'Bakar sambil dioles bumbu',
      'Sajikan hangat',
    ],
  ),

  Recipe(
    title: 'Nasi Goreng',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: '../assets/nasiGoreng.jpg',
    category: 'Sarapan',
    rating: 4.7,
    duration: '20 mnt',
    history: '10 menit yang lalu',
    ingredients: [
      'Nasi putih',
      'Telur',
      'Bawang putih',
      'Kecap',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Rawon',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: 'assets/rawon.jpg',
    category: 'Tradisional',
    rating: 4.2,
    duration: '120 mnt',
    history: '1 jam yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Ayam Geprek',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: 'assets/ayamGeprek.jpg',
    category: 'Pedas',
    rating: 5.0,
    duration: '60 mnt',
    history: '20 jam yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Es Buah',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry',
    image: 'assets/esBuah.jpg',
    category: 'Minuman',
    rating: 5.0,
    duration: '60 mnt',
    history: '2 hari yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Ayam Kecap',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: '../assets/ayamKecap.jpg',
    category: 'Makan Malam',
    rating: 4.5,
    duration: '100 mnt',
    history: '4 hari yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Nasi Uduk',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: '../assets/nasiUduk.jpg',
    category: 'Sarapan',
    rating: 3.8,
    duration: '50 mnt',
    history: '2 hari yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'Bakso',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry',
    image: '../assets/bakso.jpg',
    category: 'Sup',
    rating: 4.3,
    duration: '30 mnt',
    history: '2 hari yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),

  Recipe(
    title: 'STMJ',
    description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry' ,
    image: '../assets/stmj.jpg',
    category: 'Minuman Hangat',
    rating: 4.3,
    duration: '10 mnt',
    history: '10 hari yang lalu',
    ingredients: [
      'Kluwek',
      'Daging Sapi',
      'Rempah-rempah',
    ],
    steps: [
      'Tumis bawang putih',
      'Masukkan telur',
      'Masukkan nasi dan bumbu',
      'Aduk hingga matang',
    ],
  ),
];

// file: data/tags.dart
final initialTags = [
  'All',
  'Sarapan',
  'Jajanan Tradisional',
  'Pedas',
  'Makan Malam',
  'Minuman',
];

final additionalTags = [
  'Mie',
  'Sup',
  'Gorengan',
  'Sehat',
  'Minuman Hangat',
];
