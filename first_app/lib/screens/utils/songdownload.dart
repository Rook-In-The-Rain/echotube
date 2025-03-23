import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDownloadFolderPath() async {
  final directory = await getApplicationDocumentsDirectory();
  final downloadPath = '${directory.path}/downloads';

  // Create the folder if it doesn’t exist
  final dir = Directory(downloadPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return downloadPath;
}

Future<void> downloadAudio(String audioUrl, String fileName) async {
  try {
    String downloadFolder = await getDownloadFolderPath();
    fileName = Uri.encodeComponent(fileName);
    String filePath = '$downloadFolder/$fileName.mp3';

    Dio dio = Dio();
    await dio.download(audioUrl, filePath);

    // print('Download completed: $filePath');
  } catch (e) {
    print('Error downloading file: $e');
  }
}

Future<List<FileSystemEntity>> getDownloadedSongs() async {
  String downloadFolder = await getDownloadFolderPath();
  Directory dir = Directory(downloadFolder);
  
  if (!dir.existsSync()) {
    return []; // Return empty list if folder doesn't exist
  }

  List<FileSystemEntity> files = dir.listSync();
  return files.where((file) => file.path.endsWith('.mp3')).toList();
}