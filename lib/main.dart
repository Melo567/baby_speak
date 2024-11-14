import 'package:audio_recognition_app/status_baby.dart';
import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Speak',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StatusBaby status = StatusBaby.none;
  bool _recording = false;
  Stream<Map<dynamic, dynamic>>? result;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
      inputType: 'rawAudio',
      model: 'assets/dunstan_classifier.tflite',
      label: 'assets/dunstan_labels.txt',
      numThreads: 1,
      isAsset: true,
    );
  }

  void _recorder() {
    if (!_recording) {
      setState(() => _recording = true);
      result = TfliteAudio.startAudioRecognition(
        numOfInferences: 60,
        sampleRate: 44100,
        bufferSize: 22016,
      );
      result!.listen((event) {
        final res = event["recognitionResult"].split(" ")[1];
        status = StatusBaby.fromLabel(res);
        if (status != StatusBaby.none) {
          _stop();
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              height: 200,
              child: Center(
                child: Text(status.label),
              ),
            ),
          );
        }
      }).onDone(() {
        setState(() {
          _recording = false;
        });
      });
    }
  }

  void _stop() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _recording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            MaterialButton(
              onPressed: _recorder,
              color: _recording ? Colors.pink : Colors.grey,
              textColor: Colors.white,
              child: Icon(Icons.mic, size: 80),
              shape: CircleBorder(),
              padding: EdgeInsets.all(40),
            ),
          ],
        ),
      ),
    );
  }
}
