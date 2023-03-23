import 'dart:io';
import 'dart:typed_data';

import 'package:ai_voice/constant/constant.dart';
import 'package:ai_voice/screen/widget/player_custom.dart';
import 'package:ai_voice/screen/widget/recorder_custom.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class VTTScreen extends StatefulWidget {
  const VTTScreen({Key? key}) : super(key: key);

  @override
  State<VTTScreen> createState() => _VTTScreenState();
}

class _VTTScreenState extends State<VTTScreen> {
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
                    print(audioPath);
                    showPlayer = true;
                  },
                );
              },
            ),
    );
  }

  void convertToText() async {
    try {
      Uint8List fileContent = File(audioPath).readAsBytesSync();

      // String fileName = audioPath.split('/').last;
      // print(fileName);
      // FormData formData = FormData.fromMap({
      //   "file":
      //   await MultipartFile.fromFile(audioPath, filename:fileName),
      // });
      //
      // File file = File(audioPath);
      // if (Platform.isIOS) {
      //   file = await file.copy(file.path);
      // }

      final http = Dio();
      http.options.headers['api-key'] = Constant.apiKey;
      http.options.headers['Content-Type'] = audioPath.split('.').last;
      final result = await http.post(Constant.apiLinkVoiceToText, data: fileContent);
      print("-----result ${result.statusCode} ${result.statusMessage}");
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some thing went wrong! $e')));
    }
  }
}
