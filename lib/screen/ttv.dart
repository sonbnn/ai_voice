import 'package:ai_voice/constant/constant.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TTVScreen extends StatefulWidget {
  const TTVScreen({Key? key}) : super(key: key);

  @override
  State<TTVScreen> createState() => _TTVScreenState();
}

class _TTVScreenState extends State<TTVScreen> {
  TextEditingController textEditingController = TextEditingController();
  String? urlMP3;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Send a message'),
              controller: textEditingController,
            ),
            ElevatedButton(
              onPressed: () {
                convertToVoice();
              },
              child: const Text('Convert to voice'),
            ),
            if (urlMP3 != null)
              _buildPlayVoice()
          ],
        ),
      ),
    );
  }

  void convertToVoice() async {
    try {
      final http = Dio();
      http.options.headers['api-key'] = Constant.apiKey;
      http.options.headers['speed'] = '';
      http.options.headers['voice'] = 'banmai';
      final result = await http.post(Constant.apiLinkTextToVoice, data: textEditingController.text);
      setState(() {
        urlMP3 = result.data["async"];
        print(urlMP3);
        audioPlayer.setSourceUrl(urlMP3 ?? '');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some thing went wrong! $e')));
    }
  }

  Widget _buildPlayVoice() {
    return CircleAvatar(
      radius: 35,
      child: IconButton(
        icon: isPlaying ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
        iconSize: 50,
        onPressed: () async {
          if (isPlaying) {
            print("pause");
            await audioPlayer.pause();
          } else {
            print("play");
            await audioPlayer.play(UrlSource(urlMP3 ?? ''));
          }
        },
      ),
    );
  }
}
