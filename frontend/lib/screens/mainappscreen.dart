import 'package:first_app/screens/utils/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:first_app/screens/homepage.dart';
import 'package:first_app/screens/downloadscreen.dart';
import 'package:first_app/screens/audioplayer.dart';
import 'package:first_app/screens/likedsongscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


class MainAppScreen extends StatefulWidget{

  @override
  _MainAppScreenState createState() => _MainAppScreenState();

}

class _MainAppScreenState extends State<MainAppScreen>{
  Widget _currentScreen = HomePageScreen(); // Default screen

  void _navigateToScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
      Navigator.pop(context); // Close the drawer after selecting
    });
  }


  @override
  Widget build(BuildContext context) {
    User? _user = Provider.of<AuthProviderClass>(context).user;
   return Scaffold(
    appBar: AppBar(title: Text("Welcome, ${_user?.displayName}")),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Text("Cool App", style: TextStyle(color: Colors.white, fontSize: 24))),
          ListTile(leading: Icon(Icons.home), title: Text("Home"), onTap: () => _navigateToScreen(HomePageScreen())),
          ListTile(leading: Icon(Icons.download), title: Text("Downloads"), onTap: () => _navigateToScreen(DownloadsScreen())),
          ListTile(leading: Icon(Icons.star), title: Text("Liked Songs"), onTap: () => _navigateToScreen(LikedSongsScreen())),
          ListTile(leading: Icon(Icons.backspace), title: Text("Log Out"), onTap: () async => await Provider.of<AuthProviderClass>(context, listen: false).signOut())
        ],
      )
    ),
    body: Stack( // 👀 Ensures overlapping content doesn't cause overflow
      children: [
        Positioned.fill(child: _currentScreen), // Fills the entire available space
        Align( // 👀 Fixes bottom overflow by pinning the audio player properly
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 120, // Set exact height to avoid unexpected growth
            child: AudioPlayerWidget(),
          ),
        ),
      ],
    ),
   );
  }
}