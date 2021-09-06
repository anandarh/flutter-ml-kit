import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;
  String text = 'Waiting For Extract';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Recognition'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          // Once complete, show content
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildContent();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            Container(
              width: 200,
              height: 200,
              child: _imageFile != null
                  ? Image.file(
                      File(_imageFile!.path),
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.fitHeight,
                    )
                  : Container(
                      decoration: BoxDecoration(color: Colors.red[200]),
                      width: 200,
                      height: 200,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
            _imageFile != null
                ? Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: _extract,
                        child: Text('Extract'),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(text)
                    ],
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _extract() async {
    if (_imageFile != null) {
      final inputImage = InputImage.fromFilePath(_imageFile!.path);
      final textDetector = GoogleMlKit.vision.textDetector();
      final RecognisedText recognisedText =
          await textDetector.processImage(inputImage);

      setState(() {
        text = recognisedText.text;
      });
    }
  }
}
