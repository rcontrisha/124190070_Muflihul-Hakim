import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String favoriteKey = 'favorite_amiibos';

// Menyimpan daftar amiibo favorit
Future<void> saveFavoriteAmiibos(List<dynamic> amiibos) async {
  final prefs = await SharedPreferences.getInstance();
  final amiibosJson = jsonEncode(amiibos); // Ubah list ke JSON string
  await prefs.setString(favoriteKey, amiibosJson);
}

// Mengambil daftar amiibo favorit
Future<List<dynamic>> getFavoriteAmiibos() async {
  final prefs = await SharedPreferences.getInstance();
  final amiibosJson = prefs.getString(favoriteKey);

  if (amiibosJson != null) {
    try {
      return jsonDecode(amiibosJson); // Decode JSON string ke list
    } catch (e) {
      // Handle error in case of corrupted data
      return [];
    }
  }
  return []; // Jika kosong, kembalikan list kosong
}

// Menambahkan amiibo ke daftar favorit
Future<void> addAmiiboToFavorites(dynamic amiibo) async {
  final amiibos = await getFavoriteAmiibos();

  // Hindari duplikasi amiibo berdasarkan nama (bisa disesuaikan)
  if (!amiibos.any((fav) => fav['name'] == amiibo['name'])) {
    amiibos.add(amiibo);
    await saveFavoriteAmiibos(amiibos);
  }
}

// Menghapus amiibo dari daftar favorit
Future<void> removeAmiiboFromFavorites(String name) async {
  final amiibos = await getFavoriteAmiibos();
  final updatedAmiibos = amiibos.where((amiibo) => amiibo['name'] != name).toList();
  await saveFavoriteAmiibos(updatedAmiibos);
}

// Mengecek apakah amiibo sudah ada di favorit
Future<bool> isAmiiboFavorited(dynamic amiibo) async {
  final amiibos = await getFavoriteAmiibos();
  return amiibos.any((fav) => fav['name'] == amiibo['name']);
}
