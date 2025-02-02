import 'package:flutter/material.dart';
import 'package:project_raion/screens/users_post_page.dart';
import '../service/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<dynamic> _userPosts = [];
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchUsersPost();
  }

  //Get User Detail
  Future<void> _fetchUser() async {
    try {
      final users = await ApiService.getUserDetailById(widget.userId);
      setState(() {
        _userData = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Get All Post From User
  Future<void> _fetchUsersPost() async {
    try {
      final posts = await ApiService.getPostByUserId(widget.userId);
      setState(() {
        _userPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengambil postingan'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50,color: Colors.grey[200],),
              ),
              SizedBox(width: 16),
              Expanded(
                child:
                _userData['username'] == null ? Center(child: CircularProgressIndicator()) : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['username'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
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
                final user = _userData;

                return GestureDetector(
                  onTap: () {
                    // Navigasi ke PostPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersPostPage(postData: post, userData: user),
                      )
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey, width: 1),
                    ),
                    color: Colors.grey[300],
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username di atas
                          Text(
                            user['username'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8/2),

                          // Cek apakah ada gambar yang diunggah
                          if (post['image_url'] != null && post['image_url'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post['image_url'],
                                width: double.infinity,
                                height: 216,
                                fit: BoxFit.cover,
                              ),
                            ),

                          SizedBox(height: 8/2),

                          // Caption
                          Text(
                            post['caption'] ?? 'No caption available',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 4),

                          // Tanggal
                          Text(
                            'Posted at: ${post['created_at']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

//SizedBox(height: 20),
//           Divider(),
//           Expanded(child:
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _userPosts.isEmpty
//                   ? Center(child: Text("User ini belum memiliki postingan"))
//                   : ListView.builder(
//                       itemCount: _userPosts.length,
//                       itemBuilder: (context, index) {
//                         final post = _userPosts[index];
//                         final user = _userData;
//
//                         return Card(
//                           margin: EdgeInsets.all(10),
//                           child: ListTile(
//                             title: Text(post['caption'] ?? 'Tidak ada caption'),
//                             subtitle:
//                                 Text("Diposting pada: ${post['created_at']}"),
//                             leading: post['image_url'] != null
//                                 ? Image.network(post['image_url'],
//                                     width: 50, height: 50, fit: BoxFit.cover)
//                                 : Icon(Icons.image_not_supported),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => UsersPostPage(
//                                     postData: post,
//                                     userData: user,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
