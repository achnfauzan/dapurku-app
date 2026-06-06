import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditResepPage extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> recipeData;

  const EditResepPage({
    super.key,
    required this.recipeId,
    required this.recipeData,
  });

  @override
  State<EditResepPage> createState() => _EditResepPageState();
}

class _EditResepPageState extends State<EditResepPage> {
  final _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _durasiController;
  late String _kategori;

  late List<TextEditingController> _bahanControllers;
  late List<TextEditingController> _langkahControllers;

  final List<String> _kategoriList = [
    'Sarapan', 'Makan Siang', 'Makan Malam',
    'Camilan', 'Minuman', 'Tradisional', 'Pedas',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.recipeData;

    // Pre-fill dari data yang ada
    _judulController = TextEditingController(text: d['title'] ?? '');
    _deskripsiController = TextEditingController(text: d['description'] ?? '');
    _imageUrlController = TextEditingController(text: d['image'] ?? '');
    _durasiController = TextEditingController(text: d['duration'] ?? '');
    _kategori = _kategoriList.contains(d['category'])
        ? d['category']
        : _kategoriList.first;

    final bahan = List<String>.from(d['ingredients'] ?? []);
    _bahanControllers = bahan.isEmpty
        ? [TextEditingController()]
        : bahan.map((b) => TextEditingController(text: b)).toList();

    final langkah = List<String>.from(d['steps'] ?? []);
    _langkahControllers = langkah.isEmpty
        ? [TextEditingController()]
        : langkah.map((l) => TextEditingController(text: l)).toList();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _imageUrlController.dispose();
    _durasiController.dispose();
    for (final c in _bahanControllers) c.dispose();
    for (final c in _langkahControllers) c.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        _durasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .update({
        'title': _judulController.text.trim(),
        'description': _deskripsiController.text.trim(),
        'image': _imageUrlController.text.trim(),
        'category': _kategori,
        'duration': _durasiController.text.trim(),
        'ingredients': _bahanControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'steps': _langkahControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil diperbarui! ✅')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= HAPUS RESEP =================
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Yakin mau hapus resep ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(widget.recipeId)
                  .delete();
              Navigator.pop(context); // balik ke detail
              Navigator.pop(context); // balik ke home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resep berhasil dihapus')),
              );
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Resep'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // TOMBOL HAPUS
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
          // TOMBOL SIMPAN
          TextButton(
            onPressed: _isLoading ? null : _simpan,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== PREVIEW FOTO =====
            if (_imageUrlController.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _imageUrlController.text,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                ),
              )
            else
              _imagePlaceholder(),

            const SizedBox(height: 16),

            // ===== URL FOTO =====
            _buildLabel('URL Foto Resep'),
            _buildTextField(
              controller: _imageUrlController,
              hint: 'https://example.com/foto-resep.jpg',
              onChanged: (_) => setState(() {}),
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
                      .map((k) =>
                          DropdownMenuItem(value: k, child: Text(k)))
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
                      () => _bahanControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            ..._bahanControllers.asMap().entries.map((e) => Padding(
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
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => setState(
                              () => _bahanControllers.removeAt(e.key)),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // ===== LANGKAH =====
            Row(
              children: [
                _buildLabel('Cara Memasak'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() =>
                      _langkahControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            ..._langkahControllers.asMap().entries.map((e) => Padding(
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
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => setState(
                              () => _langkahControllers.removeAt(e.key)),
                        ),
                    ],
                  ),
                )),
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
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
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
          Icon(Icons.image_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Preview foto akan muncul di sini',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}