import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App with Backend and Frontend',
        theme: ThemeData.light(),   // Light theme
        darkTheme: ThemeData.dark(), // Dark theme
        themeMode: ThemeMode.dark, 
      home: const UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String _userData = "No user data";
  int _userId = 1;

  Future<void> fetchUser() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8000/user/${_idController.text}"));

    if (response.statusCode == 200) {
      setState(() {
        _userData = jsonDecode(response.body).toString();
      });
    } else {
      setState(() {
        _userData = "User not found";
      });
    }
  }

  Future<void> setUser() async {
    final Uri url = Uri.parse("http://127.0.0.1:8000/user/$_userId");
      Map<String, dynamic> body = {
      "name": _nameController.text,
      "age": int.tryParse(_ageController.text) ?? 2
    };
    print(url);
    try{
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
      if(response.statusCode == 200){
        setState(() {
          _userData = response.body;
          _userId++;
        });
      }
      else{
        setState(() {
          _userData = "Error ${response.statusCode}";
        });
      }
    } catch(e){
      print(e);
      setState(() {
        _userData = "Couldn't connect to backend";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simple Flutter App with Backend and Frontend")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_userData, style: const TextStyle(fontSize: 18)),
            Container(
              width: 300,
              child: Column(children: [
            const SizedBox(height: 20),
             TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Enter Name"),
            ),
            const SizedBox(height:10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: "Enter Age"),
              keyboardType: TextInputType.number,
            ),  
            const SizedBox(height:10),
            ElevatedButton(onPressed: setUser, child: Text("Add User $_userId")),
            const SizedBox(height:20),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: "Enter ID to fetch"),
              )
          ])),
          SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchUser,
              child: const Text("Fetch User"),
            ),
          ],
        ),
      ),
    );
  }
}