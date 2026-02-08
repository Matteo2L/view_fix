import 'package:shared_preferences/shared_preferences.dart';

class FavoriteUrl {
  final String url;
  final String title;
  final DateTime dateAdded;

  FavoriteUrl({
    required this.url,
    required this.title,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory FavoriteUrl.fromMap(Map<String, dynamic> map) {
    return FavoriteUrl(
      url: map['url'] as String,
      title: map['title'] as String,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
    );
  }
}

class FavoritesService {
  static const String _key = 'favorites';
  static late SharedPreferences _prefs;

  // Initialize the service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get all favorites
  static Future<List<FavoriteUrl>> getFavorites() async {
    final jsonList = _prefs.getStringList(_key) ?? [];
    return jsonList
        .map((jsonString) => FavoriteUrl.fromMap(
              Map<String, dynamic>.from(
                Map.from(Uri.parse('?$jsonString').queryParameters)
                  ..forEach((key, value) {
                    try {
                      Map<String, dynamic> map = {};
                      final entries = jsonString.split('|||');
                      for (var entry in entries) {
                        final parts = entry.split('::');
                        if (parts.length == 2) {
                          map[parts[0]] = parts[1];
                        }
                      }
                      return;
                    } catch (e) {
                      return;
                    }
                  }),
              ),
            ))
        .toList();
  }

  // Get favorites using a simpler approach
  static Future<List<FavoriteUrl>> getFavoritesSimple() async {
    try {
      final jsonList = _prefs.getStringList(_key) ?? [];
      return jsonList
          .map((jsonString) {
            final parts = jsonString.split('|||');
            if (parts.length == 3) {
              return FavoriteUrl(
                url: parts[0],
                title: parts[1],
                dateAdded: DateTime.parse(parts[2]),
              );
            }
            return null;
          })
          .whereType<FavoriteUrl>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add a favorite
  static Future<void> addFavorite(String url, String title) async {
    final favorites = await getFavoritesSimple();

    // Check if URL already exists
    final exists = favorites.any((fav) => fav.url == url);
    if (exists) return;

    final newFavorite = FavoriteUrl(
      url: url,
      title: title.isEmpty ? url : title,
      dateAdded: DateTime.now(),
    );

    final jsonList = [
      ...favorites.map(
          (f) => '${f.url}|||${f.title}|||${f.dateAdded.toIso8601String()}'),
      '${newFavorite.url}|||${newFavorite.title}|||${newFavorite.dateAdded.toIso8601String()}',
    ];

    await _prefs.setStringList(_key, jsonList);
  }

  // Remove a favorite
  static Future<void> removeFavorite(String url) async {
    final favorites = await getFavoritesSimple();
    final filtered = favorites.where((fav) => fav.url != url).toList();

    final jsonList = filtered
        .map((f) => '${f.url}|||${f.title}|||${f.dateAdded.toIso8601String()}')
        .toList();

    await _prefs.setStringList(_key, jsonList);
  }

  // Check if URL is favorite
  static Future<bool> isFavorite(String url) async {
    final favorites = await getFavoritesSimple();
    return favorites.any((fav) => fav.url == url);
  }

  // Clear all favorites
  static Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}
