import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart';
import 'package:first_app/screens/utils/authprovider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

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


  Future<void> clearLikedSongs() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('liked_songs');

    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await collectionRef.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Songs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: clearLikedSongs,
            tooltip: "Clear all liked songs",
          ),
        ],
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
            itemCount: songs.length,
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
    );
  }
}