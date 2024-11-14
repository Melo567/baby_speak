import 'package:baby_speak/core/status_baby.dart';
import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:tflite_audio/tflite_audio.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              height: MediaQuery.sizeOf(context).height,
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
        child: RippleAnimation(
          child: MaterialButton(
            onPressed: _recorder,
            textColor: Colors.white,
            splashColor: Colors.transparent,
            child: Icon(
              Icons.mic,
              size: 80,
              color: Colors.white,
            ),
            shape: CircleBorder(),
            padding: EdgeInsets.all(40),
          ),
          color: _recording ? Colors.pink : Colors.transparent,
          delay: const Duration(
            milliseconds: 100,
          ),
          repeat: true,
          minRadius: _recording ? 100 : 0,
          ripplesCount: 6,
          duration: const Duration(
            milliseconds: 6 * 300,
          ),
        ),
      ),
    );
  }
}
