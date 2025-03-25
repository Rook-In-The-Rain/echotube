import 'package:flutter/material.dart';
import 'package:first_app/screens/downloadscreen.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "My App",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context); // Closes the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text("Downloaded Songs"),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DownloadsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}