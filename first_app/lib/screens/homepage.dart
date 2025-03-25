import 'package:first_app/screens/utils/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart';
import 'dart:convert';


class HomePageScreen extends StatefulWidget{
  const HomePageScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>{
    final TextEditingController _urlController = TextEditingController();
    String? _songTitle;

    Future<void> getSong() async {
    setState(() {
      _songTitle = "Fetching...";
    });
    final String? refreshToken = Provider.of<AuthProviderClass>(context,listen: false).refreshToken;
    final String? accessToken = await Provider.of<AuthProviderClass>(context, listen: false).googleAccessToken;
    print("Got token, $accessToken and refresh token, $refreshToken");
    // https://backend-for-podcast-app-production.up.railway.app/
    final response = await http.post(
    Uri.parse('https://backend-for-podcast-app-production.up.railway.app/download_audio?url=${_urlController.text}&token=$accessToken')
  );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        print("Got song title!");
        Provider.of<AudioProvider>(context, listen: false).setAudioUrl(data["audio_url"], _songTitle);
      });
    } else {
      setState(() {
        _songTitle = "Song not found";
      });
    }
  }


  @override
  Widget build(BuildContext context){
    _songTitle = Provider.of<AudioProvider>(context, listen: false).title;
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