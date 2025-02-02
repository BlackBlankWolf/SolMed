import 'package:flutter/material.dart';
import 'package:project_raion/screens/post_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_raion/service/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _id = '';
  List<dynamic> _userPosts = [];
  Map<String, dynamic> userData = {};
  bool _isLoading = true;
  final _token = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  //Get Data Current User
  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final _token = prefs.getString('token');

      final profileData = await ApiService.getCurrentUser(_token!);

      setState(() {
        userData = profileData;
        _username = profileData['username'];
        _id = profileData['id'];
      });
      _fetchUserPosts(_id);
    } catch (error) {
      print('Error fetching profile: $error');
      setState(() => _isLoading = false);
    }
  }

  //Get All Post User
  Future<List<dynamic>> _fetchUserPosts(String userId) async {
    try {
      final posts = await ApiService.getPostByUserId(userId);
      setState(() {
        _userPosts = posts;
        _isLoading = false;
      });
      return _userPosts;
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() => _isLoading = false);
      return [];
    }
  }

  //Navigation Screen Edit Profile
  void _navigateToEditProfile() {
    // Navigasi ke halaman Edit Profile
    Navigator.pushNamed(context, '/editprofile').then((_) {
      _fetchProfile(); // Refresh profil setelah kembali dari Edit Profile
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('M Y P R O F I L E')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50,color: Colors.grey[200],),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _username,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToEditProfile,
                        child: Text("Edit Profile"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _userPosts.isEmpty
                    ? Center(child: Text("Belum ada postingan"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _userPosts.length,
                          itemBuilder: (context, index) {
                            final post = _userPosts[index];

                            return GestureDetector(
                              onTap: () {
                                // Navigasi ke PostPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostPage(
                                        postData: post, userData: userData),
                                  ),
                                ).then((updated) {
                                  if (updated == true) {
                                    _fetchProfile();
                                  }
                                });
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                color: Colors.grey[300],
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Username di atas
                                      Text(
                                        _username,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8 / 2),

                                      // Cek apakah ada gambar yang diunggah
                                      if (post['image_url'] != null &&
                                          post['image_url'].isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            post['image_url'],
                                            width: double.infinity,
                                            height: 216,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                      SizedBox(height: 8 / 2),

                                      // Caption
                                      Text(
                                        post['caption'] ??
                                            'No caption available',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 4),

                                      // Tanggal
                                      Text(
                                        'Posted at: ${post['created_at']}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[800]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
