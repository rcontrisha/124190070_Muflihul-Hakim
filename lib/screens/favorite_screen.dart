import 'package:flutter/material.dart';
import 'package:muflihul_hakim_124190070/services/favorite_service.dart'; // Import favorite_service
import 'package:shared_preferences/shared_preferences.dart'; // Untuk SharedPreferences
import 'detail_screen.dart'; // Import halaman DetailScreen

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Memuat daftar favorit menggunakan favorite_service
  void _loadFavorites() async {
    final favorites = await getFavoriteAmiibos();
    setState(() {
      _favorites = List<Map<String, dynamic>>.from(favorites);
    });
  }

  // Menghapus item dari favorit
  void _removeFavorite(int index) async {
    final amiibo = _favorites[index];
    await removeAmiiboFromFavorites(amiibo['name']);
    setState(() {
      _favorites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${amiibo['name']} removed from favorites')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return Dismissible(
                  key: Key(favorite['name']),
                  onDismissed: (direction) => _removeFavorite(index),
                  child: ListTile(
                    leading: Image.network(favorite['image']),
                    title: Text(favorite['name']),
                    subtitle: Text(favorite['gameSeries']),
                    onTap: () {
                      // Navigasi ke halaman detail saat item diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(amiibo: favorite),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
