import 'dart:convert';
import 'dart:html' as html;

class RecentlyViewedHelper {
  static const _key = 'recently_viewed';

  static Future<void> add(String recipeTitle) async {
    List<Map<String, dynamic>> list = get();
    list.removeWhere((e) => e['title'] == recipeTitle);
    list.insert(0, {
      'title': recipeTitle,
      'viewedAt': DateTime.now().toIso8601String(),
    });
    if (list.length > 10) list = list.take(10).toList();
    html.window.localStorage[_key] = jsonEncode(list);
  }

  static List<Map<String, dynamic>> get() {
    final raw = html.window.localStorage[_key];
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static String timeAgo(String isoString) {
    final date = DateTime.parse(isoString);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 7).floor()} minggu lalu';
  }
}