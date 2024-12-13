import 'package:flutter/material.dart';
import 'package:muflihul_hakim_124190070/services/favorite_service.dart'; // Import favorite_service

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> amiibo;

  DetailScreen({required this.amiibo});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Mengecek apakah amiibo sudah ada di daftar favorit
  void _checkIfFavorite() async {
    bool isFavorited = await isAmiiboFavorited(widget.amiibo);
    setState(() {
      _isFavorite = isFavorited;
    });
  }

  // Menambahkan amiibo ke favorit
  void _addToFavorite() async {
    await addAmiiboToFavorites(widget.amiibo);
    setState(() {
      _isFavorite = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.amiibo['name']} added to favorites')),
    );
  }

  // Menghapus amiibo dari favorit
  void _removeFromFavorite() async {
    await removeAmiiboFromFavorites(widget.amiibo['name']);
    setState(() {
      _isFavorite = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${widget.amiibo['name']} removed from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amiibo Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              if (_isFavorite) {
                _removeFromFavorite();
              } else {
                _addToFavorite();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.amiibo['image'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Name Section
            Text(
              widget.amiibo['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Details Section
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow(
                      'Amiibo Series', widget.amiibo['amiiboSeries']),
                  _buildDetailRow('Character', widget.amiibo['character']),
                  _buildDetailRow('Game Series', widget.amiibo['gameSeries']),
                  _buildDetailRow('Type', widget.amiibo['type']),
                  _buildDetailRow('Head', widget.amiibo['head']),
                  _buildDetailRow('Tail', widget.amiibo['tail']),
                  SizedBox(height: 16),
                  // Release Dates Section
                  Text(
                    'Release Dates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(
                      height: 10,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.black45),
                  ..._buildReleaseDates(widget.amiibo['release']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReleaseDates(Map<String, dynamic> releaseDates) {
    return releaseDates.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              entry.key,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              entry.value ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
