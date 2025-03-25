import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart'; // Import the provider
import 'package:flutter/services.dart';


class DownloadsScreen extends StatefulWidget {
  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
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

 
  @override
  Widget build(BuildContext context) {
    final downloads = Provider.of<DownloadProvider>(context).downloads;
    return KeyboardListener(focusNode: _focusNode, autofocus: true, onKeyEvent: _handleKeyEvent, child:
      Scaffold(
        appBar: AppBar(title: Text("Downloads")),
        body: ListView.builder(
          itemCount: downloads.length,
          controller: _scrollController,
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
      )
    );
  }
}