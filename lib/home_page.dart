import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:funs_and_music/play_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterAudioQuery flutterAudioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];

  int currentIndex = 0;

  final GlobalKey<PlayPageState> key = GlobalKey<PlayPageState>();
  @override
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await flutterAudioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      } else {
        if (currentIndex < 0) {
          currentIndex--;
        }
      }
    }
    key.currentState.setsong(songs[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funs and Musics'),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return songs.isEmpty
              ? const CircularProgressIndicator()
              : ListTile(
                  onTap: () {
                    currentIndex = index;
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return PlayPage(
                          songInfo: songs[currentIndex],
                          changeTrack: changeTrack,
                          key: key);
                    }));
                  },
                  leading: CircleAvatar(
                    // backgroundColor: Colors.amber,
                    backgroundImage: songs[index].albumArtwork == null
                        ? const AssetImage('assets/image/dog.jpg')
                        : FileImage(
                            File(songs[index].albumArtwork),
                          ),
                  ),
                  title: Text(songs[index].title),
                  subtitle: Text(songs[index].artist),
                );
        },
        separatorBuilder: (_, i) => const Divider(),
        itemCount: songs.length,
      ),
    );
  }
}
