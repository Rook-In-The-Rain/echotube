import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart';
import 'package:first_app/screens/utils/authprovider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class Likedsongscreen extends StatefulWidget {

  @override
  _LikedSongScreenState createState() => _LikedSongScreenState();
}

class _LikedSongScreenState extends State<Likedsongscreen> {

  Stream<List<Map<String, dynamic>>> getLikedSongs() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('liked_songs')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

    final FocusNode _focusNode = FocusNode();
    @override
    void initState() {
      super.initState();
      _focusNode.requestFocus();
      Future.microtask(() =>
          Provider.of<DownloadProvider>(context, listen: false).loadDownloads());
    }

  final ScrollController _scrollController = ScrollController();

    void _handleKeyEvent(KeyEvent event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _scrollController.animateTo(
            _scrollController.offset + 50, // Scroll down
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _scrollController.animateTo(
            _scrollController.offset - 50, // Scroll up
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
    }

      Future<void> getSong(context, youtubelink) async {
          Provider.of<AudioProvider>(context, listen: false).setTitle("Fetching...", autoUpdate: false);
        final String? accessToken = await Provider.of<AuthProviderClass>(context, listen: false).googleAccessToken;
        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        // https://backend-for-podcast-app-production.up.railway.app/, http://127.0.0.1:8000
        final response = await http.post(
        Uri.parse('https://backend-for-podcast-app-production.up.railway.app/download_audio?url=$youtubelink&token=$accessToken&firebase_uid=$uid')
      );
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
            print("Got song title!");
            Provider.of<AudioProvider>(context, listen: false).youtubeUrl = youtubelink;
            Provider.of<AudioProvider>(context, listen: false).setTitle(data["title"]);
            Provider.of<AudioProvider>(context, listen: false).setAudioUrl(data["audio_url"], Provider.of<AudioProvider>(context, listen: false).title);
        } else {
          Provider.of<AudioProvider>(context, listen: false).setTitle("No Song Found");
        }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(focusNode: _focusNode, autofocus: true, onKeyEvent: _handleKeyEvent, child:
 Scaffold(
      appBar: AppBar(
        title: const Text("Liked Songs")
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getLikedSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No liked songs yet."));
          }

          final songs = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 120),
            itemCount: songs.length,
            controller: _scrollController,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                title: Text(song['title'], overflow: TextOverflow.ellipsis),
                subtitle: Text(song['url'], overflow: TextOverflow.ellipsis),
                leading: const Icon(Icons.music_note),
                onTap: () => getSong(context, song["url"]),
              );
            },
          );
        },
      ),
      )
    );
  }
}