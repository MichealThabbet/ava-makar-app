import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ItemType { book, manuscript, study }

const itemTypeAr = {ItemType.book: 'كتاب', ItemType.manuscript: 'مخطوطة', ItemType.study: 'دراسة'};
const langAr = {'ar': 'عربي', 'cp': 'قبطي معرّب', 'co': 'قبطي', 'en': 'إنجليزي'};

class LibraryItem {
  LibraryItem.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      title = j['title'] as String,
      subtitle = j['subtitle'] as String,
      type = ItemType.values.byName(j['type'] as String),
      langs = (j['langs'] as List).cast<String>(),
      source = j['source'] as String,
      readable = j['status'] == 'sample',
      reader = j['reader'] as String?,
      shelfMark = j['shelfMark'] as String?,
      holdingLibrary = j['holdingLibrary'] as String?;

  final String id, title, subtitle, source;
  final ItemType type;
  final List<String> langs;
  final bool readable;
  final String? reader, shelfMark, holdingLibrary;

  /// Badges shown on covers: type + languages.
  List<String> get badges => [itemTypeAr[type]!, for (final l in langs) langAr[l] ?? l];
}

/// Loaded content plus the user's favourites and reading position.
class AppData extends ChangeNotifier {
  AppData._(this.sample, this.items, this._prefs);

  final Map<String, dynamic> sample;
  final List<LibraryItem> items;
  final SharedPreferences? _prefs;

  static Future<AppData> load() async {
    final sample =
        jsonDecode(await rootBundle.loadString('assets/data/preview_sample.json', cache: false))
            as Map<String, dynamic>;
    final lib =
        jsonDecode(await rootBundle.loadString('assets/data/library.json', cache: false)) as Map<String, dynamic>;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      prefs = null; // storage unavailable (private mode): app still works, nothing persists
    }
    return AppData._(sample, [
      for (final i in lib['items'] as List) LibraryItem.fromJson(i as Map<String, dynamic>),
    ], prefs);
  }

  LibraryItem byId(String id) => items.firstWhere((i) => i.id == id);

  Set<String> get favourites => (_prefs?.getStringList('favourites') ?? const []).toSet();
  bool isFavourite(String id) => favourites.contains(id);

  void toggleFavourite(String id) {
    final f = favourites;
    f.contains(id) ? f.remove(id) : f.add(id);
    _prefs?.setStringList('favourites', f.toList());
    notifyListeners();
  }

  /// Last opened readable item and its scroll offset.
  String? get lastReadId => _prefs?.getString('lastRead');
  double get lastReadOffset => _prefs?.getDouble('lastReadOffset') ?? 0;

  void saveProgress(String id, double offset) {
    _prefs?.setString('lastRead', id);
    _prefs?.setDouble('lastReadOffset', offset);
    notifyListeners();
  }

  double offsetFor(String id) => lastReadId == id ? lastReadOffset : 0;

  /// Plain search over titles, subtitles and the sample texts.
  List<SearchHit> search(String q) {
    final t = q.trim();
    if (t.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final i in items) {
      if (i.title.contains(t) || i.subtitle.contains(t)) hits.add(SearchHit(i, i.subtitle));
    }
    final k = sample['kholagy'] as Map<String, dynamic>;
    for (final s in (k['segments'] as List).cast<Map<String, dynamic>>()) {
      final ar = s['ar'] as String;
      if (ar.contains(t)) hits.add(SearchHit(byId('kholagy'), _snippet(ar, t)));
    }
    final b = (sample['bostan'] as Map<String, dynamic>)['paragraph'] as Map<String, dynamic>;
    final bt = b['text'] as String;
    if (bt.contains(t)) hits.add(SearchHit(byId('bostan'), _snippet(bt, t)));
    return hits;
  }

  static String _snippet(String text, String q) {
    final i = text.indexOf(q);
    final s = (i - 40).clamp(0, text.length);
    final e = (i + q.length + 60).clamp(0, text.length);
    return '${s > 0 ? '… ' : ''}${text.substring(s, e).trim()}${e < text.length ? ' …' : ''}';
  }
}

class SearchHit {
  const SearchHit(this.item, this.snippet);
  final LibraryItem item;
  final String snippet;
}
