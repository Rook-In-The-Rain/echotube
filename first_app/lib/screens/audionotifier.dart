import 'package:flutter/material.dart';


class AudioProvider extends ChangeNotifier {
  String _audioUrl = "https://youtu.be/MkYMss0iUZY";

  String get audioUrl => _audioUrl;

  void setAudioUrl(String url) {
    _audioUrl = url;
    notifyListeners();  // Updates UI when URL changes
  }
}