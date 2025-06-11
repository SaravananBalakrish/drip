import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class OpenAIChatScreen extends StatefulWidget {
  const OpenAIChatScreen({super.key});

  @override
  State<OpenAIChatScreen> createState() => _OpenAIChatScreenState();
}

class _OpenAIChatScreenState extends State<OpenAIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  File? _selectedImage;
  File? _recordedAudio;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _recorder.openRecorder();
  }

  Future<void> _initPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _sendMessage() async {
    String text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null && _recordedAudio == null) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'image': _selectedImage,
        'audio': _recordedAudio
      });
      _textController.clear();
      _selectedImage = null;
      _recordedAudio = null;
    });

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer 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',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": text}
      ]
    });

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
      });
    } else {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Failed to get response.'});
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      if (path != null) {
        setState(() {
          _recordedAudio = File(path);
        });
      }
    } else {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audio.aac';
      await _recorder.startRecorder(toFile: path);
    }
    setState(() => _isRecording = !_isRecording);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenAI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ListTile(
                  title: Text("${msg['sender']}: ${msg['text'] ?? ''}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg['image'] != null) Image.file(msg['image'], height: 100),
                      if (msg['audio'] != null)
                        Text("Audio: ${msg['audio'].path.split('/').last}")
                    ],
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Image.file(_selectedImage!, height: 100),
          if (_recordedAudio != null)
            Text("Audio ready: ${_recordedAudio!.path.split('/').last}"),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _pickImageFromCamera,
              ),
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                onPressed: _toggleRecording,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(hintText: "Type your message"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
