import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class TambahResepPage extends StatefulWidget {
  const TambahResepPage({super.key});

  @override
  State<TambahResepPage> createState() => _TambahResepPageState();
}

class _TambahResepPageState extends State<TambahResepPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  bool _isLoading = false;

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _durasiController = TextEditingController();
  String _kategori = 'Sarapan';
  String? _imageBase64;

  final List<TextEditingController> _bahanControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _langkahControllers = [
    TextEditingController(),
  ];

  final List<String> _kategoriList = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Camilan',
    'Minuman',
    'Tradisional',
    'Pedas',
  ];

  // ================= SIMPAN =================
  Future<void> _simpan() async {
    final imageOk = _imageBase64 != null || _imageUrlController.text.isNotEmpty;
    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        !imageOk ||
        _durasiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String authorName = _user?.displayName ?? '';
      if (authorName.isEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user?.uid)
            .get();
        authorName = doc.data()?['displayName'] ?? 'Anonim';
      }

      String authorImage = '';
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid)
          .get();
      final userData = userDoc.data();
      if (userData?['photoBase64'] != null) {
        authorImage = 'data:image/jpeg;base64,${userData!['photoBase64']}';
      } else if (_user?.photoURL != null) {
        authorImage = _user!.photoURL!;
      }

      await FirebaseFirestore.instance.collection('recipes').add({
        'title': _judulController.text.trim(),
        'description': _deskripsiController.text.trim(),
        'image': _imageBase64 != null
            ? 'data:image/jpeg;base64,$_imageBase64'
            : _imageUrlController.text.trim(),
        'category': _kategori,
        'duration': _durasiController.text.trim(),
        'rating': 0.0,
        'history': 'Baru saja',
        'ingredients': _bahanControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'steps': _langkahControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'authorId': _user?.uid,
        'authorName': authorName,
        'authorImage': authorImage,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil ditambahkan! 🎉')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // PILIH FOTO
  Future<void> _pilihFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBase64 = base64Encode(bytes);
      _imageUrlController.clear();
    });
  }

  void _showPilihFotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.blue,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pilihFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.blue,
              ),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pilihFoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Resep'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _simpan,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== PREVIEW FOTO =====
            GestureDetector(
              onTap: _showPilihFotoSheet,
              child: _imageBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(_imageBase64!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _imageUrlController.text.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _imageUrlController.text,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _photoPlaceholder(),
                      ),
                    )
                  : _photoPlaceholder(),
            ),

            const SizedBox(height: 12),

            // TOMBOL PILIH FOTO
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showPilihFotoSheet,
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.blue,
                ),
                label: Text(
                  _imageBase64 != null ? 'Ganti Foto' : 'Pilih Foto',
                  style: const TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ATAU URL
            _buildLabel('Atau masukkan URL Foto'),
            _buildTextField(
              controller: _imageUrlController,
              hint: 'https://example.com/foto.jpg',
              onChanged: (_) => setState(() => _imageBase64 = null),
            ),

            const SizedBox(height: 16),

            // ===== JUDUL =====
            _buildLabel('Judul Resep'),
            _buildTextField(
              controller: _judulController,
              hint: 'Contoh: Nasi Goreng Spesial',
            ),

            const SizedBox(height: 16),

            // ===== DESKRIPSI =====
            _buildLabel('Deskripsi'),
            _buildTextField(
              controller: _deskripsiController,
              hint: 'Ceritakan sedikit tentang resep ini...',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // ===== KATEGORI =====
            _buildLabel('Kategori'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _kategori,
                  isExpanded: true,
                  items: _kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setState(() => _kategori = val!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== DURASI =====
            _buildLabel('Durasi Memasak'),
            _buildTextField(
              controller: _durasiController,
              hint: 'Contoh: 30 mnt',
            ),

            const SizedBox(height: 24),

            // ===== BAHAN =====
            Row(
              children: [
                _buildLabel('Bahan-bahan'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(
                    () => _bahanControllers.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            ..._bahanControllers.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: e.value,
                        hint: 'Contoh: 200 gram daging sapi',
                      ),
                    ),
                    if (_bahanControllers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            setState(() => _bahanControllers.removeAt(e.key)),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== LANGKAH =====
            Row(
              children: [
                _buildLabel('Cara Memasak'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(
                    () => _langkahControllers.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            ..._langkahControllers.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: e.value,
                        hint: 'Langkah ${e.key + 1}...',
                        maxLines: 2,
                      ),
                    ),
                    if (_langkahControllers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            setState(() => _langkahControllers.removeAt(e.key)),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ===== TOMBOL SIMPAN =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Resep',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text('Tap untuk pilih foto', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
