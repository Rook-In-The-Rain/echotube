import 'package:flutter/material.dart';
import 'dart:io';
import 'package:first_app/screens/utils/songdownload.dart';


class AudioProvider with ChangeNotifier {
  String _audioUrl = "";
  String _filePath = "";
  String _title = "";
  bool _isFile = false;

  String get audioUrl => _audioUrl;
  String get title => _title;
  String get filePath => _filePath;
  bool get isFile => _isFile;

  void setAudioUrl(String url, String title) {
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