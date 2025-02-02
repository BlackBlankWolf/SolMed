import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_raion/screens/search_result_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_raion/service/api_service.dart';
import 'package:project_raion/screens/users_profile_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _userResults = [];
  bool _isUserLoading = false;
  Timer? _debounce;


  @override
  void initState() {
    super.initState();
  }

  //Search and Get All User From Username
  void _searchUsers(String query) async {
    setState(() => _isUserLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("Token tidak ditemukan");

      final users = await ApiService.searchUser(token, query);
      setState(() {
        _userResults = users ?? [];
        _isUserLoading = false;
      });
    } catch (e) {
      setState(() {
        _userResults = [];
        _isUserLoading = false;
      });
    }
  }

  //Timer Refresh
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _userResults.clear();
        });
      } else {
        _searchUsers(query);
      }
    });
  }

  //Navigation To Screen Search Result
  void _navigateToSearchResults() {
    if (_searchController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(query: _searchController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari username atau caption...",
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _userResults.clear();
                    });
                  },
                )
                    : Icon(Icons.search, color: Colors.black,),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (query) => _navigateToSearchResults(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Hasil Pencarian User
                  Text("Hasil Pencarian User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _isUserLoading && _userResults.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : _userResults.isEmpty
                      ? Text("Tidak ada user ditemukan", style: TextStyle(color: Colors.grey))
                      : Column(
                    children: _userResults.map((user) {
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(user['username'] ?? 'Unknown User'),
                        subtitle: Text("User"),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(userId: user['id']),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (_isUserLoading && _userResults.isNotEmpty) Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}