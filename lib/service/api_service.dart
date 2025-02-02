import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';


class ApiService {
  static const String baseUrl = 'https://raion-battlepass.elginbrian.com';


  // General method for handling HTTP responses
  static dynamic handleResponse(http.Response response) {
    print('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }

  // Register User
  static Future<Map<String, dynamic>> registerUser(String email, String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    return handleResponse(response);
  }

  // Login User
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return handleResponse(response);
  }

  // Get Current User Info
  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final url = Uri.parse('$baseUrl/api/auth/current-user');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );
    return handleResponse(response)['data'];
  }

  //Change Password
  static Future<Map<String, dynamic>> changePassword(String token, String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/auth/change-password');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(
          {"new_password": newPassword, "old_password": oldPassword}),
    );

    return handleResponse(response);
  }

  // Get All Posts
  static Future<List<dynamic>> getAllPosts() async {
    final url = Uri.parse('$baseUrl/api/posts');
    final response = await http.get(url);
    return handleResponse(response)['data'];
  }

  // Create Post
  static Future<Map<String, dynamic>> createPost(String token, String caption, File? image) async {
    final url = Uri.parse('$baseUrl/api/posts');
    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = '$token';
    request.fields['caption'] = caption;
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else {
      print('tidak ada image dikirim');
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return handleResponse(http.Response(responseBody, response.statusCode));
  }

  // Delete Post
  static Future<void> deletePost(String token, String postId) async {
    final url = Uri.parse('$baseUrl/api/posts/$postId');
    final response = await http.delete(
      url,
      headers: {'Authorization': '$token'},
    );
    handleResponse(response);
  }

  //Update Caption Post
  static Future<void> updatePost(String token, String postId, String newCaption) async {
    final url = Uri.parse('$baseUrl/api/posts/$postId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({'caption': newCaption}),
    );

    handleResponse(response);
  }

  // Get Post By User ID
  static Future<List<dynamic>> getPostByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/api/posts/user/$userId');
    final response = await http.get(
      url, // Endpoint untuk mendapatkan postingan user tertentu
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return handleResponse(response)['data'];
  }

  // Search Posts
  static Future<List<dynamic>> searchPosts(String token, String query) async {
    final url = Uri.parse('$baseUrl/api/search/posts?query=$query');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return handleResponse(response)['data'];
  }

  // Search User
  static Future<List<dynamic>> searchUser(String token, String query) async {
    final url = Uri.parse('$baseUrl/api/search/users?query=$query');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return handleResponse(response)['data'];
  }

  // Get UserDetail By ID
  static Future<Map<String, dynamic>> getUserDetailById(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');
    final response = await http.get(url);

    return handleResponse(response)['data'];
  }

  //Update User Information
  static Future<Map<String, dynamic>> updateUserInformation(
      String token, String newUsername) async {
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login kembali.');
    }

    final url = Uri.parse('$baseUrl/api/users');
    final response = await http.put(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': newUsername}),
    );

    print('Edit Profile Response: ${response.statusCode} - ${response.body}');
    return handleResponse(response);
  }
}

//kode baru
//
// class ApiService {
//   static const String baseUrl = "https://raion-battlepass.elginbrian.com/api";
//
//   /// Login User
//   Future<String?> login(String email, String password) async {
//     final url = Uri.parse('$baseUrl/auth/login');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({"email": email, "password": password}),
//     );
//
//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       return data['data']['token'];
//     } else {
//       print('Login Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Register User
//   Future<bool> register(String username, String email, String password) async {
//     final url = Uri.parse('$baseUrl/auth/register');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({"username": username, "email": email, "password": password}),
//     );
//
//     return response.statusCode == 201;
//   }
//
//   /// Change Password
//   Future<bool> changePassword(String token, String oldPassword, String newPassword) async {
//     final url = Uri.parse('$baseUrl/auth/change-password');
//     final response = await http.put(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({"old_password": oldPassword, "new_password": newPassword}),
//     );
//
//     return response.statusCode == 200;
//   }
//
//   /// Get Current User Info
//   Future<Map<String, dynamic>?> getCurrentUser(String token) async {
//     final url = Uri.parse('$baseUrl/auth/current-user');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Get User Info Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Get All Posts
//   Future<List<dynamic>?> getPosts() async {
//     final url = Uri.parse('$baseUrl/posts');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Get Posts Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Get Posts by User
//   Future<List<dynamic>?> getPostsByUser(String userId) async {
//     final url = Uri.parse('$baseUrl/posts/user/$userId');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Get Posts by User Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Create Post
//   Future<bool> createPost(String token, String caption, [String? imagePath]) async {
//     final url = Uri.parse('$baseUrl/posts');
//     final request = http.MultipartRequest('POST', url)
//       ..headers['Authorization'] = 'Bearer $token'
//       ..fields['caption'] = caption;
//
//     if (imagePath != null) {
//       request.files.add(await http.MultipartFile.fromPath('image', imagePath));
//     }
//
//     final response = await request.send();
//
//     return response.statusCode == 201;
//   }
//
//   /// Update Post Caption
//   Future<bool> updatePost(String token, String postId, String newCaption) async {
//     final url = Uri.parse('$baseUrl/posts/$postId');
//     final response = await http.put(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({"caption": newCaption}),
//     );
//
//     return response.statusCode == 200;
//   }
//
//   /// Delete Post
//   Future<bool> deletePost(String token, String postId) async {
//     final url = Uri.parse('$baseUrl/posts/$postId');
//     final response = await http.delete(
//       url,
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     return response.statusCode == 204;
//   }
//
//   /// Search Posts
//   Future<List<dynamic>?> searchPosts(String query) async {
//     final url = Uri.parse('$baseUrl/search/posts?query=$query');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Search Posts Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Search Users
//   Future<List<dynamic>?> searchUsers(String query) async {
//     final url = Uri.parse('$baseUrl/search/users?query=$query');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Search Users Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Get All Users
//   Future<List<dynamic>?> getUsers() async {
//     final url = Uri.parse('$baseUrl/users');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Get Users Error: ${response.body}');
//       return null;
//     }
//   }
//
//   /// Get User by ID
//   Future<Map<String, dynamic>?> getUserById(String userId) async {
//     final url = Uri.parse('$baseUrl/users/$userId');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       print('Get User by ID Error: ${response.body}');
//       return null;
//     }
//   }
// }

// ini Kode lama
//   // Register User
//   static Future<Map<String, dynamic>> registerUser(
//       String email, String username, String password) async {
//     final url = Uri.parse('$baseUrl/api/auth/register');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'email': email,
//         'username': username,
//         'password': password,
//       }),
//     );
//
//     // Cetak respons untuk debugging
//     print('Register Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       // Respons sukses
//       return jsonDecode(response.body);
//     } else {
//       // Respons gagal
//       throw Exception('Failed to register: ${response.body}');
//     }
//   }
//
//
//   // Login User
//   static Future<Map<String, dynamic>> loginUser(String email, String password) async {
//     final url = Uri.parse('$baseUrl/api/auth/login');
//     print('Login Request: email=$email, password=$password');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'email': email,
//         'password': password,
//       }),
//     );
//
//
//     print('Login Response: ${response.statusCode} - ${response.body}');
//     if (response.statusCode == 400 || response.statusCode == 401) {
//       final error = jsonDecode(response.body);
//       throw Exception('Login failed: ${error['message']}');
//     }
//
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       return jsonDecode(response.body); // Sukses
//     } else {
//       throw Exception('Login failed: ${response.body}'); // Error
//     }
//   }
//
//   static Future<Map<String, dynamic>> getCurrentUser(String token) async {
//     final url = Uri.parse('$baseUrl/api/auth/current-user');
//     final response = await http.get(
//       url,
//       headers: {'Authorization': '$token'},
//     );
//
//     print('Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body); // Sukses
//     } else {
//       throw Exception('Failed to fetch user: ${response.body}'); // Error
//     }
//   }
//
//   // Get All Posts
//   static Future<List<dynamic>> getAllPosts() async {
//     final url = Uri.parse('$baseUrl/api/posts');
//     final response = await http.get(url);
//
//     print('Get Posts Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       throw Exception('Failed to fetch posts: ${response.body}');
//     }
//   }
//
//   // Create Post
//   static Future<Map<String, dynamic>> createPost(String token, String caption) async {
//     final url = Uri.parse('$baseUrl/api/posts');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token'
//       },
//       body: jsonEncode({'caption': caption}),
//     );
//
//     print('Create Post Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to create post: ${response.body}');
//     }
//   }
//
//   // Delete Post
//   static Future<void> deletePost(String token, String postId) async {
//     final url = Uri.parse('$baseUrl/api/posts/$postId');
//     final response = await http.delete(
//       url,
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     print('Delete Post Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete post: ${response.body}');
//     }
//   }
//
//   // Search Posts
//   static Future<List<dynamic>> searchPosts(String query) async {
//     final url = Uri.parse('$baseUrl/api/search/posts?query=$query');
//     final response = await http.get(url);
//
//     print('Search Posts Response: ${response.statusCode} - ${response.body}');
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     } else {
//       throw Exception('Failed to search posts: ${response.body}');
//     }
//   }
// }
//
