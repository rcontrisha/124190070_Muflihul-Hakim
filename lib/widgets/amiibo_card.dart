import 'package:flutter/material.dart';

class AmiiboCard extends StatelessWidget {
  final dynamic amiibo; // Data untuk satu item Amiibo
  final VoidCallback onTap; // Fungsi yang dipanggil saat kartu diklik
  final VoidCallback onFavoriteTap; // Fungsi saat tombol favorite diklik
  final bool isFavorite; // Menentukan apakah item ini favorit

  const AmiiboCard({
    Key? key,
    required this.amiibo,
    required this.onTap,
    required this.onFavoriteTap,
    this.isFavorite = false, // Default tidak favorit
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 3,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              amiibo['image'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            amiibo['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Game Series : ${amiibo['gameSeries']}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: onFavoriteTap, // Mengupdate status favorit
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
