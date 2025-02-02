import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  String? _imageUrl; // Untuk Web

  // Choose Image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print(pickedFile?.path);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _imageUrl = pickedFile.path; // Web menggunakan path
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }

  }

  //Create Post
  Future<void> _createPost() async {
    if (_captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Caption tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print(_imageUrl);
      print(_imageFile?.path);
      final response = await ApiService.createPost(token!,_captionController.text, _imageFile);

      print('Create Post Success: $response');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post berhasil dibuat')),
      );

      // Kembali ke Homepage setelah sukses
      Navigator.pop(context, true);
    } catch (error) {
      print('Error creating post: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat post')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Postingan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            if(_imageFile != null)
              Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
            TextFormField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.image, color: Colors.blue),
                  onPressed: _pickImage,
                ),
              ),
            ),

            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createPost,
              child: Text('Posting'),
            ),
          ],
        ),
      ),
    );
  }
}
