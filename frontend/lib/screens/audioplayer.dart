import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/audionotifier.dart';
import 'package:first_app/screens/utils/songdownload.dart';
import 'dart:io';

class AudioPlayerWidget extends StatefulWidget{
  const AudioPlayerWidget({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerState createState() => _AudioPlayerState();

}

class _AudioPlayerState extends State<AudioPlayerWidget>{
  late AudioPlayer _audioPlayer;
  double _currentPosition = 0;
  double _totalDuration = 1; 
  bool _isPlaying = false;
  bool _isLooping = false;
  String _currentAudioUrl = "";
  String _currentsongtitle = "";

  @override
  void initState(){
     super.initState();
     _audioPlayer = AudioPlayer();
  }//https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? title =  Provider.of<AudioProvider>(context).title;
    if(title == "") return;
    bool isFile = Provider.of<AudioProvider>(context).isFile;
    if(isFile){
      String filePath_ = Provider.of<AudioProvider>(context).filePath;
      print("GOT FILE PATH $filePath_");
      _loadAudio(filePath_, title, isFile);
    }
    else{
      String audioUrl = Provider.of<AudioProvider>(context).audioUrl;
      _loadAudio(audioUrl, title, isFile);
    }
  }

  Future<void> _loadAudio(audioUrl, title, isFile) async {
    // await _audioPlayer.setAsset("assets/edited_bully.mov");
    print("got video title $title as well as URL $audioUrl");
    setState(() {
      _currentAudioUrl = audioUrl;
      _currentsongtitle = title;
    });
    if(!isFile){
      await _audioPlayer.setUrl(_currentAudioUrl);
    }
    else{
      await _audioPlayer.setFilePath(_currentAudioUrl);
    }
    _listenToPlayback();
  }


  void _listenToPlayback() {
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration.inSeconds.toDouble();
        });
      }
    });
    _audioPlayer.positionStream.listen((duration) {
      setState(() {
        _currentPosition = duration.inSeconds.toDouble();
      });
    });
  }

  void _setVolume(double volume){
    _audioPlayer.setVolume(volume);
    Provider.of<AudioProvider>(context, listen: false).setVolume(volume);
  }

  void _likeSong(){
    print("got hereee");
    Provider.of<AudioProvider>(context, listen: false).likeSong();
  }

  Future<void> _downloadSong() async {
    if(_currentAudioUrl == "" || _currentsongtitle == "" || Provider.of<AudioProvider>(context, listen: false).isFile) return;
    print("DOWNLOADINGGGGGG");
    await downloadAudio(_currentAudioUrl, _currentsongtitle);
  }

  void _seekTo(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));  // 🔹 Seek function
  }

  void _togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() => _isPlaying = _audioPlayer.playing);
  }

  void _toggleLoop(){
    setState(() {
        _audioPlayer.setLoopMode(
        _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one
      );
      _isLooping = !_isLooping;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: Container(
         color: Colors.black,
         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
         child: Column(
        mainAxisSize: MainAxisSize.min,  // Shrink to fit
        children: [
          SeekBarWidget(
            currentPosition: _currentPosition,
            totalDuration: _totalDuration,
            onSeek: _seekTo,  // 🔹 Callback for seeking
          ),
          PlaybackControlsWidget(
            isPlaying: _isPlaying,
            onPlayPause: _togglePlayPause,  // 🔹 Callback for play/pause
            onLoop: _toggleLoop,
            isLooping: _isLooping,
            onDownload: _downloadSong,
            onVolumeChange: _setVolume,
            onLike: _likeSong,
          ),
        ],
      ),
      )
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // ✅ Clean up when widget is destroyed
    super.dispose();
  }
}

class SeekBarWidget extends StatelessWidget{
  final double currentPosition;
  final double totalDuration;
  final ValueChanged<double> onSeek;

  const SeekBarWidget({
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    super.key
  });

  @override
  Widget build(BuildContext context){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatDuration(currentPosition)),
      SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: Slider(value: currentPosition, min: 0, max: totalDuration, onChanged: onSeek)),
      Text(_formatDuration(totalDuration))
    ],
    );
  }

    String _formatDuration(double seconds) {
    int min = (seconds / 60).floor();
    int sec = (seconds % 60).floor();
    return "$min:${sec.toString().padLeft(2, '0')}";
  }
}

class PlaybackControlsWidget extends StatelessWidget{
  final bool isPlaying;
  final bool isLooping;
  final VoidCallback onLoop;
  final VoidCallback onPlayPause;
  final Future<void> Function() onDownload;
  final ValueChanged<double> onVolumeChange;
  final VoidCallback onLike;

  const PlaybackControlsWidget({
    required this.isPlaying,
    required this.onPlayPause,
    required this.isLooping,
    required this.onLoop,
    required this.onDownload,
    required this.onVolumeChange,
    required this.onLike,
    super.key
  });

  @override
  Widget build(BuildContext build){
    double volume = Provider.of<AudioProvider>(build, listen: false).volume;
    // bool isLiked = Provider.of<AudioProvider>(build, listen: false).isLiked;
    return Row(
      children: [
          Consumer<AudioProvider>(
        builder: (context, provider, child) {
          return SizedBox(width: 2, child: IconButton(
            icon: Icon(provider.isLiked ? Icons.star : Icons.star_border),
            onPressed: () {
              provider.likeSong(); // Just update liked state, not full rebuild
            },
          ));
        },
      ),
      if (Platform.isMacOS) const Spacer(flex: 2),
        Expanded(flex: (Platform.isMacOS ? 5 : 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: () async { await onDownload(); print("Download completed!");}, icon: Icon(Icons.download)),
        IconButton(onPressed: onPlayPause, icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), color: Colors.white),
        IconButton(
          icon: Icon(
          isLooping ? Icons.repeat_one : Icons.repeat,
            color: isLooping ? Colors.blue : Colors.white,
          ),
          onPressed: onLoop,
        )
        ])),
            if (Platform.isMacOS) 
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, size: 20),
                      Expanded(
                        child: Slider(value: volume, min: 0.0, max:1.0, onChanged: onVolumeChange),
                      ),
                    ],
                  ),
                )
              )
      ],
    );
  }
}