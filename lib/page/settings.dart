import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _user = FirebaseAuth.instance.currentUser;
  bool _notifAktif = false;
  bool _loadingNotif = true;

  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _loadNotifSetting();
  }

  Future<void> _loadNotifSetting() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    final data = doc.data();
    setState(() {
      _notifAktif = data?['notifikasi'] ?? false;
      _loadingNotif = false;
    });
  }

  Future<void> _toggleNotif(bool val) async {
    if (_user == null) return;
    setState(() => _notifAktif = val);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .set({'notifikasi': val}, SetOptions(merge: true));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
            'Akun kamu akan dihapus permanen beserta semua data. Tindakan ini tidak bisa dibatalkan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .delete();
                await _user!.delete();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal hapus akun: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTentangApp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: Colors.blue, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Resep App',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Versi 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi resep masakan Indonesia yang memudahkan kamu menemukan, menyimpan, dan berbagi resep favoritmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'Pengguna';
    final photoUrl = _user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // ================= PROFIL SINGKAT =================
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: photoUrl != null
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          (displayName.isNotEmpty ? displayName[0] : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _user?.email ?? '',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/edit_profil'),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),

          // ================= PREFERENSI =================
          _sectionTitle('Preferensi'),
          _card(children: [
            _loadingNotif
                ? const ListTile(
                    leading: Icon(Icons.notifications_outlined,
                        color: primaryBlue),
                    title: Text('Notifikasi'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : SwitchListTile(
                    secondary: const Icon(
                        Icons.notifications_outlined,
                        color: primaryBlue),
                    title: const Text('Notifikasi',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _notifAktif ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                          fontSize: 12,
                          color: _notifAktif
                              ? Colors.blue
                              : Colors.grey),
                    ),
                    value: _notifAktif,
                    activeColor: Colors.blue,
                    onChanged: _toggleNotif,
                  ),
          ]),

          // ================= APLIKASI =================
          _sectionTitle('Aplikasi'),
          _card(children: [
            _item(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: _showTentangApp,
            ),
            const Divider(height: 1, indent: 56),
            _item(
              icon: Icons.privacy_tip_outlined,
              title: 'Kebijakan Privasi',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _item(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _item(
              icon: Icons.mail_outline,
              title: 'Hubungi Kami',
              subtitle: 'resepapp@gmail.com',
              onTap: () {},
            ),
          ]),

          // ================= AKUN =================
          _sectionTitle('Akun'),
          _card(children: [
            _item(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: _showLogoutDialog,
            ),
            const Divider(height: 1, indent: 56),
            _item(
              icon: Icons.delete_outline,
              title: 'Hapus Akun',
              color: Colors.red,
              onTap: _showDeleteAccountDialog,
            ),
          ]),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Resep App v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black45,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
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
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right,
          size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}