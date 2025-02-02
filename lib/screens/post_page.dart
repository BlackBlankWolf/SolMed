import 'package:flutter/material.dart';
import 'package:project_raion/screens/profile_page.dart';
import 'package:project_raion/service/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class PostPage extends StatefulWidget {
  final Map<String, dynamic> postData;
  final Map<String, dynamic> userData;


  PostPage({required this.postData, required this.userData});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController _captionController = TextEditingController();
  String _token = '';
  bool succes = false;

  @override
  void initState() {
    super.initState();
    _getToken();
    _captionController.text = widget.postData['caption'] ?? "";

  }
  Future<void> _getToken() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if(token != null){
      _token = token;
    }

  }

  // Fungsi untuk update caption
  Future<void> _updatePost() async {
    print(_token);
    String newCaption = _captionController.text;
    if (newCaption.isEmpty) return;
    try{
      await ApiService.updatePost(_token, widget.postData['id'], newCaption);
      Navigator.pop(context,true);

    } catch (e) {
      print("Error: $e");
    }
  }

  // Fungsi untuk menghapus postingan
  Future<void> _deletePost() async {
    try {
      await ApiService.deletePost(_token, widget.postData['id'].toString());
      Navigator.pop(context,true);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Dialog konfirmasi hapus postingan
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Postingan"),
        content: Text("Apakah Anda yakin ingin menghapus postingan ini?"),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _deletePost();
            },
          ),
        ],
      ),
    );
  }

  // Dialog untuk edit caption
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Caption"),
        content: TextField(
          controller: _captionController,
          decoration: InputDecoration(hintText: "Masukkan caption baru"),
        ),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Simpan", style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(context);
              _updatePost();
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Tampilkan ikon titik tiga hanya jika pengguna adalah pemilik postingan
          if (widget.userData['id'] == widget.postData['user_id'])
            PopupMenuButton<String>(
              color: Colors.blue[200],
              onSelected: (value) {
                if (value == 'edit') _showEditDialog();
                if (value == 'delete') _showDeleteDialog();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text("Edit")),
                PopupMenuItem(value: 'delete', child: Text("Delete")),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.postData.containsKey('image_url') && widget.postData['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.postData['image_url'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              widget.postData['caption'] ?? "Tidak ada caption",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.userData['username'] ?? 'Unknown',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Di upload pada : ${widget.postData['created_at'] ?? 'Tidak diketahui'}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
