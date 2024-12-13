import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muflihul_hakim_124190070/services/favorite_service.dart';
import 'package:muflihul_hakim_124190070/widgets/amiibo_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _amiiboList;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _favoriteAmiibos;

  @override
  void initState() {
    super.initState();
    _amiiboList = fetchAllAmiibos(); // Default: Fetch all data
    _favoriteAmiibos = getFavoriteAmiibos(); // Ambil daftar favorit
  }

  /// Fetch all Amiibos
  Future<List<dynamic>> fetchAllAmiibos() async {
    final response =
        await http.get(Uri.parse('https://www.amiiboapi.com/api/amiibo'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['amiibo'];
    } else {
      throw Exception('Failed to load all Amiibos');
    }
  }

  /// Fetch Amiibos by partial head
  Future<List<dynamic>> fetchAmiibosByHead(String head) async {
    final response = await http
        .get(Uri.parse('https://www.amiiboapi.com/api/amiibo/?head=$head'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> allAmiibos = data['amiibo'] ?? [];

      // Filter Amiibos based on partial matching of head in any of the elements
      List<dynamic> filteredAmiibos = allAmiibos.where((amiibo) {
        String amiiboHead = amiibo['head'] ?? '';
        return amiiboHead.contains(head);
      }).toList();

      return filteredAmiibos; // Return filtered results
    } else {
      throw Exception('Failed to load Amiibos by head: $head');
    }
  }

  /// Perform search when user submits the head value
  void _performSearch() {
    final head = _searchController.text.trim();
    if (head.isEmpty) {
      setState(() {
        _amiiboList =
            fetchAllAmiibos(); // Reset to all data if search is cleared
      });
    } else {
      setState(() {
        _amiiboList = fetchAmiibosByHead(head);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          'Nintendo Amiibo List',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Head...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (value) => _performSearch(),
              ),
            ),
          ),
          // Content List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _amiiboList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Amiibos found.'));
                } else {
                  final amiiboList = snapshot.data!;
                  return FutureBuilder<List<dynamic>>(
                    future: _favoriteAmiibos, // Ambil daftar favorit
                    builder: (context, favSnapshot) {
                      if (favSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (favSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${favSnapshot.error}'));
                      } else if (favSnapshot.data == null ||
                          favSnapshot.data!.isEmpty) {
                        return ListView.builder(
                          itemCount: amiiboList.length,
                          itemBuilder: (context, index) {
                            final amiibo = amiiboList[index];
                            return AmiiboCard(
                              amiibo: amiibo,
                              isFavorite: false, // Tidak ada favorit
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(amiibo: amiibo),
                                  ),
                                );
                              },
                              onFavoriteTap: () {
                                addAmiiboToFavorites(
                                    amiibo); // Tambahkan ke favorit
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${amiibo['name']} added to favorites',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        final favorites = favSnapshot.data!;
                        return ListView.builder(
                          itemCount: amiiboList.length,
                          itemBuilder: (context, index) {
                            final amiibo = amiiboList[index];
                            final isFavorite = favorites.any((fav) =>
                                fav['name'] ==
                                amiibo['name']); // Cek apakah favorit
                            return AmiiboCard(
                              amiibo: amiibo,
                              isFavorite: isFavorite, // Tentukan favorit
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(amiibo: amiibo),
                                  ),
                                );
                              },
                              onFavoriteTap: () async {
                                final amiibo = amiiboList[index];
                                final isFavorite = favorites.any(
                                    (fav) => fav['name'] == amiibo['name']);

                                if (isFavorite) {
                                  await removeAmiiboFromFavorites(
                                      amiibo['name']); // Hapus dari favorit
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${amiibo['name']} removed from favorites'),
                                    ),
                                  );
                                } else {
                                  await addAmiiboToFavorites(
                                      amiibo); // Tambahkan ke favorit
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${amiibo['name']} added to favorites'),
                                    ),
                                  );
                                }

                                // Refresh daftar favorit
                                final updatedFavorites =
                                    await getFavoriteAmiibos(); // Ambil favorit terbaru

                                setState(() {
                                  // Update UI dengan data favorit terbaru
                                  _favoriteAmiibos =
                                      Future.value(updatedFavorites);
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
