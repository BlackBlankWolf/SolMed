import 'package:flutter/material.dart';
import 'package:project_raion/screens/search_page.dart';
import 'package:project_raion/screens/sign_up_page.dart';
import 'package:project_raion/screens/home_page_post.dart';
import 'package:project_raion/screens/profile_page.dart';
import 'package:project_raion/screens/edit_profile_page.dart';
import 'package:project_raion/screens/sign_in_page.dart';
import 'package:project_raion/screens/welcome_page.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_raion/widgets/navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raion Battlepass',
      debugShowCheckedModeBanner: false,

      initialRoute: '/welcomepage',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: AppBarTheme(backgroundColor: Colors.grey[200], centerTitle: true, titleTextStyle: TextStyle(color: Colors.blue[600], fontSize: 24)),
          drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[200]),
        iconButtonTheme: IconButtonThemeData(style: ButtonStyle(
          iconColor: MaterialStateProperty.all(Colors.black),
        ),
        ),
        fontFamily: 'Poppins', // Ganti dengan nama font yang sudah didaftarkan
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      routes: {
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/homepage': (context) => NavigationsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/searchpage': (context) => NavigationsScreen(),
        '/editprofile': (context) => EditProfileScreen(),
        '/settings': (context) => NavigationsScreen(),
      },
    );
  }
}
