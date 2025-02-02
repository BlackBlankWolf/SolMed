import 'package:flutter/material.dart';
import 'package:project_raion/screens/users_post_page.dart';
import 'package:project_raion/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  SearchResultsPage({required this.query});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<dynamic> _postResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts(widget.query);
  }

  //Search and Get Post From Caption
  Future<void> _fetchPosts(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final posts = await ApiService.searchPosts(token, query);
      setState(() {
        _postResults = posts ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _postResults = [];
        _isLoading = false;
      });
    }
  }

  // Navigate To Screen Post Page With Get User Detail First
  Future<void> _navigateToPostPage(Map<String, dynamic> post) async {
    try {
      setState(() => _isLoading = true);
      final user = await ApiService.getUserDetailById(post['user_id']); // Ambil user berdasarkan ID post
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UsersPostPage(postData: post, userData: user),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _postResults.isEmpty
            ? Center(child: Text("Tidak ada postingan ditemukan"))
            : ListView.builder(
          itemCount: _postResults.length,
          itemBuilder: (context, index) {
            final post = _postResults[index];
            return Card(
              margin: EdgeInsets.all(2),
              child: ListTile(
                title: Text(post['caption'] ?? 'Tidak ada caption'),
                subtitle: Text("Diposting pada: ${post['created_at']}"),
                onTap: () => _navigateToPostPage(post), // Ambil user dulu sebelum pindah halaman
              ),
            );
          },
        ),
      ),
    );
  }
}
