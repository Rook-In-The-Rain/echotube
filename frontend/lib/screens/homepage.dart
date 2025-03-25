import 'package:first_app/screens/utils/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';


class HomePageScreen extends StatefulWidget{
  const HomePageScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>{
    final TextEditingController _urlController = TextEditingController();

    @override
    void initState() {
      super.initState();
       WidgetsBinding.instance.addPostFrameCallback((_) {
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);

        if (!audioProvider.hasRunStartup) {
          getSong(justStarted: true);  // Only runs once
          audioProvider.completeStartup();
        }
      });
    }
    
    Future<void> getSong({bool justStarted = false}) async {
    setState(() {
      if(justStarted) return;
      Provider.of<AudioProvider>(context, listen: false).setTitle("Fetching...", autoUpdate: false);
    });
    final String? accessToken = await Provider.of<AuthProviderClass>(context, listen: false).googleAccessToken;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    print("Got access token! $accessToken");
    final String youtubelink= justStarted ? "" : _urlController.text;
    print("VIDEO LINK -> $youtubelink");
    // print("Got token, $accessToken and refresh token, $refreshToken");
    // https://backend-for-podcast-app-production.up.railway.app/, http://127.0.0.1:8000
    final response = await http.post(
    Uri.parse('https://backend-for-podcast-app-production.up.railway.app/download_audio?url=$youtubelink&token=$accessToken&firebase_uid=$uid')
  );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        print("Got song title!");
        print("Audio path -> ${data["audio_url"]}");
        Provider.of<AudioProvider>(context, listen: false).youtubeUrl = youtubelink;
        Provider.of<AudioProvider>(context, listen: false).setTitle(data["title"]);
        Provider.of<AudioProvider>(context, listen: false).setAudioUrl(data["audio_url"], Provider.of<AudioProvider>(context, listen: false).title);
      });
    } else {
      setState(() {
      Provider.of<AudioProvider>(context, listen: false).setTitle("No Song Found");
      });
    }
  }


  @override
  Widget build(BuildContext context){
    String? songTitle = Provider.of<AudioProvider>(context, listen: false).title;
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to homepage")),
      body: Center(child:
        Column(children: [
          Text("Input the song url below..current song: $songTitle"),
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