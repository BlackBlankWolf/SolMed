import 'package:flutter/material.dart';
import 'package:project_raion/screens/users_profile_page.dart';
import 'package:project_raion/service/api_service.dart';
import 'package:project_raion/model/post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_raion/screens/create_post_page.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late PageController pageController;
  List<Post> _posts = [];
  Map<String, String> _usernames = {};
  bool _isLoading = true;
  String username = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      _fetchPosts();
    });
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('token'); // Ambil token dari SharedPreferences

      if (token == null) {
        // Jika token tidak ada, kembali ke login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final userData = await ApiService.getCurrentUser(token);

      // Panggil API untuk mengambil data user saat ini
    } catch (error) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchUsers(String userId) async {
    try {
      if (_usernames.containsKey(userId)) return;
      final usersData = await ApiService.getUserDetailById(userId);

      setState(() {
        if (usersData != null && usersData['username'] != null) {
          _usernames[userId] =
              usersData['username']; // Simpan username dalam map
        }
      });
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        _isLoading = false;
      });

    }
  }

  Future<void> _fetchPosts() async {
    try {
      final postsData = await ApiService.getAllPosts();
      setState(() {
        _posts = postsData.map((post) => Post.fromJson(post)).toList();
        _isLoading = false;
      });

      await Future.wait(_posts.map((post) => _fetchUsers(post.userId)));
    } catch (error) {
      print('Error fetching posts: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat postingan')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.apps_outlined, color: Colors.blue,),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _fetchPosts, // Refresh data
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 56.0), child:
                Icon(Icons.person,
                  size: 72,
                  color: Colors.blue,
                ),
              ),
              Divider(
                indent: 24,
                endIndent: 24,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('H O M E'),
                onTap: () {
                  setState(() {
                    Navigator.pushReplacementNamed(context, '/homepage');
                  });
                },
              ),
              ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('S E T T I N G S'),
                  onTap: () {
                    setState(() async{
                      Navigator.pushReplacementNamed(context, '/settings');
                    });
                  }),
              ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('L O G O U T'),
                  onTap: () {
                    setState(() async{
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // Hapus token saat logout
                      Navigator.pushReplacementNamed(context, '/login');
                    });
                  }),

            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(child: Text('Belum ada postingan'))
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final username = _usernames[post.userId] ?? 'Unknown User';

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        // Tambahkan border di sini
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username di atas
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(userId: post.userId),
                                  ),
                                );
                              },
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8/2),

                            // Gambar di tengah
                            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.imageUrl!,
                                  width: double.infinity,
                                  height: 216,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            SizedBox(height: 8/2),

                            // Caption + Created At
                            Text(
                              post.caption ?? 'No caption available',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Posted at: ${post.createdAt}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,color: Colors.grey[200],),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
      ),
    );
  }
}
