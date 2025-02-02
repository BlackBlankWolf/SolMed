import 'package:flutter/material.dart';

class UsersPostPage extends StatelessWidget {
  final Map<String, dynamic> postData;
  final Map<String, dynamic> userData;
  UsersPostPage({required this.postData, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postData.containsKey('image_url') && postData['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  postData['image_url'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              postData['caption'] ?? "Tidak ada caption",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              userData['username'] ?? 'Unknown',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Tanggal: ${postData['created_at'] ?? 'Tidak diketahui'}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
