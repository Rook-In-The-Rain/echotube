import 'package:flutter/material.dart';
import 'dart:io';
import 'package:first_app/screens/utils/songdownload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class AudioProvider with ChangeNotifier {
  String _audioUrl = "";
  String _filePath = "";
  String? _title = "No Song";
  String? _youtubeUrl = "";
  bool _isFile = false;
  double _volume = 1.0;
  bool _isLiked = false;
  Set<String> _likedSongs = {};
  Set<String> get likedSongs => _likedSongs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLiking = false;
  bool _hasRunStartup = false;

  String get audioUrl => _audioUrl;
  String? get title => _title;
  String get filePath => _filePath;
  bool get isFile => _isFile;
  double get volume => _volume;
  bool get isLiked => _isLiked;
  String? get youtubeUrl => _youtubeUrl;
  bool get hasRunStartup => _hasRunStartup;

  set youtubeUrl(String? url){
    _youtubeUrl = url;
  }

  void completeStartup(){
    _hasRunStartup = true;
  }


  AudioProvider(){
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore.collection('users').doc(user.uid).collection('liked_songs').get();
    _likedSongs = snapshot.docs.map((doc) => doc['url'] as String).toSet();
    notifyListeners();
  }

  Future<void> toggleLikeSong(String? url, String? title) async {
    if (_isLiking || url == null) return; // Prevent spamming
    _isLiking = true;

    final user = _auth.currentUser;
    if (user == null) return;
    String songID = base64Url.encode(utf8.encode(url));
    bool alreadyLiked = _likedSongs.contains(url);

    final songRef = _firestore.collection('users').doc(user.uid).collection('liked_songs').doc(songID);

    if (alreadyLiked) {
      await songRef.delete();
      _likedSongs.remove(url);
    } else {
      await songRef.set({'title': title, 'url': url});
      _likedSongs.add(url);
    }
    await Future.delayed(Duration(milliseconds: 500)); // Prevents rapid taps
    _isLiking = false;
    _isLiked = !_isLiked;
    print(_likedSongs);
  }

  void setAudioUrl(String url, String? title) {
    _audioUrl = url;
    _title = title;
    _isFile = false;
    notifyListeners();  // Updates UI when URL changes
  }

  void setFilePath(String path, String title){
    _filePath = path;
    _title = title;
    _isFile = true;
    notifyListeners();
  }

  void setTitle(String title, {bool autoUpdate = true}){
    _title = title;
    if(!autoUpdate) return;
    notifyListeners();
  }

  void likeSong(){
    print("got here");
    if(isFile && _title != "") return;
    print("Liked song!");
    toggleLikeSong(_youtubeUrl, _title);
  }


  void setVolume(double newVolume){
    _volume = newVolume;
  }
}


class DownloadProvider with ChangeNotifier {
  List<FileSystemEntity> _downloads = [];

  List<FileSystemEntity> get downloads => _downloads;

  DownloadProvider() {
    loadDownloads(); // Automatically load when provider is created
  }

  Future<void> loadDownloads() async {
    final downloadDir = Directory(await getDownloadFolderPath()); // Replace with actual path
    print("GOT DOWNLOADS FOLDER PATH $downloadDir");
    if (downloadDir.existsSync()) {
      _downloads = downloadDir.listSync(); 
      notifyListeners();
    }
  }

  void deleteDownload(String filePath) async {
    try {
      print("Deleting FILE from $filePath");
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        downloads.remove(filePath);
        notifyListeners();
      }
      else{
        print("No file");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }
}