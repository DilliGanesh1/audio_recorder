import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_save/widgets/creteaElevatedButton.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as path;

class SoundSave extends StatefulWidget {
  const SoundSave({super.key});

  @override
  State<SoundSave> createState() => _SoundSaveState();
}

class _SoundSaveState extends State<SoundSave> {
  bool _playAudio = false;
  String? pathToAudio;
  FlutterSoundRecorder? _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  String _timerText = '00:00:00';
  final id = new DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() async {
    pathToAudio = '/sdcard/Music/audio_$id.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession?.openRecorder();
    await _recordingSession
        ?.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Recorder"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _timerText,
              style: const TextStyle(fontSize: 70, color: Colors.black),
            ),
            // ElevatedButton.icon(
            //     onPressed: () {},
            //     icon: const Icon(Icons.mic),
            //     label: const Text("Record")),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.mic,
                  iconColor: Colors.deepPurple,
                  onPressFunc: startRecording,
                ),
                const SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.deepPurple,
                  onPressFunc: stopRecording,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              icon: _playAudio
                  ? const Icon(
                      Icons.stop,
                    )
                  : const Icon(Icons.play_arrow),
              label: _playAudio
                  ? const Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    )
                  : const Text(
                      "Play",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession?.openRecorder();
    await _recordingSession?.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    StreamSubscription recorderSubscription =
        _recordingSession!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _timerText = timeText.substring(0, 8);
      });
    });
  }

  Future<String?> stopRecording() async {
    _recordingSession?.closeRecorder();
    return await _recordingSession?.stopRecorder();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}
