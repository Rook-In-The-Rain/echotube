import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:first_app/screens/audionotifier.dart';
import 'dart:convert';


class HomePageScreen extends StatefulWidget{
  const HomePageScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>{
    final TextEditingController _urlController = TextEditingController();
    String _songTitle = "No song";

    Future<void> getSong() async {
    setState(() {
      _songTitle = "Fetching...";
    });
    final uri = Uri.http("127.0.0.1:8000", "/fetch_title", {"url": _urlController.text});
    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _songTitle = data["title"];
        Provider.of<AudioProvider>(context, listen: false).setAudioUrl(_urlController.text);
      });
    } else {
      setState(() {
        _songTitle = "Song not found";
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to homepage")),
      body: Center(child:
        Column(children: [
          Text("Input the song url below..current song: $_songTitle"),
          SizedBox(height: 20),
          SizedBox(width: 200,
          child: TextField(controller: _urlController,
              decoration: const InputDecoration(labelText: "Enter URL"),)
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: getSong, child: Text("Update URL"))
        ],)
      ),
    );
  }

}