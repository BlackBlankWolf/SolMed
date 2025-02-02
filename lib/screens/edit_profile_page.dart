import 'package:flutter/material.dart';
import 'package:project_raion/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _username;
  String? _email;
  bool _isLoading = true;
  String? token;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      if (token != null) {
        _fetchProfile();
        }
    });
  }

  // Get Current User Data
  Future<void> _fetchProfile() async {
    try {
      final profileData = await ApiService.getCurrentUser(token!);

      setState(() {
        _username = profileData['username'];
        _email = profileData['email'];
        _usernameController.text = _username!;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching profile: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Update Profile
  Future<void> _editProfile() async {
    if (_usernameController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.updateUserInformation(token! ,_usernameController.text);
      print('Edit Profile Success: $response');
      setState(() {
        _username = _usernameController.text;
        _isLoading = false;
      });

      Navigator.pop(context,true);
    } catch (error) {
      print('Error updating profile: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Change Password
  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.changePassword(
        token!,
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      print('Change Password Success: $response');

      // Kosongkan field setelah sukses
      _oldPasswordController.clear();
      _newPasswordController.clear();

      //
      Navigator.pop(context,true);
    } catch (error) {
      print('Error changing password: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 20),
              Text('Email: $_email', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editProfile,
                child: Text('Update Profile'),
              ),
              SizedBox(height: 30),
              Divider(),
              SizedBox(height: 10),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Ganti Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
