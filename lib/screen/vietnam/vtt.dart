import 'dart:io';
import 'dart:typed_data';

import 'package:ai_voice/constant/constant.dart';
import 'package:ai_voice/screen/widget/player_custom.dart';
import 'package:ai_voice/screen/widget/recorder_custom.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class VTTScreenVN extends StatefulWidget {
  const VTTScreenVN({Key? key}) : super(key: key);

  @override
  State<VTTScreenVN> createState() => _VTTScreenVNState();
}

class _VTTScreenVNState extends State<VTTScreenVN> {
  bool showPlayer = false;
  String audioPath = '';
  String textRender = '';

  @override
  void initState() {
    getPermission();
    showPlayer = false;
    super.initState();
  }

  void getPermission() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.mediaLibrary.request();
    await Permission.accessMediaLocation.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: showPlayer
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AudioPlayerCustom(
                source: audioPath,
                onUpload: () {
                  convertToText();
                },
                onDelete: () {
                  setState(
                    () => showPlayer = false,
                  );
                },
              ),
            )
          : AudioRecorder(
              onStop: (path) {
                setState(
                  () {
                    audioPath = path;
                    showPlayer = true;
                  },
                );
              },
            ),
    );
  }

  void convertToText() async {
    try {

      FormData formData = FormData.fromMap({
        "file": File(audioPath).readAsBytes()
      });

      final http = Dio();
      http.options.headers['api-key'] = Constant.apiKey;
      http.options.headers['Content-Type'] = '${audioPath.split('.').last}';
      final result = (await http.post(Constant.apiLinkVoiceToText, data:  File(audioPath).readAsBytes()));
      if(result.data["status"] == 500){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.data["message"])));
      }
      print(result.data.toString());
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some thing went wrong! $e')));
    }
  }
}
