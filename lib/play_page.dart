import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class PlayPage extends StatefulWidget {
  static const routeName = 'playPage';
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<PlayPageState> key;
  PlayPage({this.songInfo, this.changeTrack, this.key}) : super(key: key);

  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  double value = 0;
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setsong(widget.songInfo);
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player?.dispose();
  }

  void setsong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    changeState();
    player.positionStream.listen((Duration) {
      currentValue = Duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('songs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.amber,
              child: Text(value.toInt().toString()),
            ),
            Slider(
                max: maximumValue,
                min: minimumValue,
                value: currentValue,
                onChanged: (val) {
                  setState(() {
                    currentValue = value;
                    player.seek(
                      Duration(
                        milliseconds: currentValue.round(),
                      ),
                    );
                  });
                }),
            Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                transform: Matrix4.translationValues(0, -15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currentTime),
                    Text(endTime),
                  ],
                )),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_outlined),
                    onPressed: () {
                      widget.changeTrack(false);
                    },
                  ),
                  IconButton(
                    icon: isPlaying
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                    onPressed: () {
                      changeState();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_outlined),
                    onPressed: () {
                      widget.changeTrack(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
