import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart'; // Import the provider

class DownloadsScreen extends StatefulWidget {
  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DownloadProvider>(context, listen: false).loadDownloads());
  }

 
  @override
  Widget build(BuildContext context) {
    final downloads = Provider.of<DownloadProvider>(context).downloads;
    return Scaffold(
      appBar: AppBar(title: Text("Downloads")),
      body: ListView.builder(
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final file = downloads[index];
          return ListTile(
            title: Text(Uri.decodeComponent(file.path.split('/').last)), // Show filename
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Provider.of<DownloadProvider>(context, listen: false).deleteDownload(file.path);
              }),
            onTap: () {
               Provider.of<AudioProvider>(context, listen: false).setFilePath(file.path, Uri.decodeComponent(file.path.split('/').last));
            },
          );
        },
      )
    );
  }
}