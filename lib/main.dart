import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_compare/image_compare.dart';

void main() {
  runApp(PhotoMatchApp());
}

class PhotoMatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Match App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? storedPhoto;
  File? capturedPhoto;
  bool isMatching = false;

  Future<void> selectPhoto() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        storedPhoto = File(pickedImage.path);
        isMatching = false;
      });
    }
  }

  Future<void> capturePhoto() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        capturedPhoto = File(pickedImage.path);
        isMatching = true;
        _comparePhotos();
      });
    }
  }

  Future<void> _comparePhotos() async {
    if (storedPhoto != null && capturedPhoto != null) {
      final storedBytes = await storedPhoto!.readAsBytes();
      final capturedBytes = await capturedPhoto!.readAsBytes();

      var storedImage = img.decodeImage(storedBytes);
      var capturedImage = img.decodeImage(capturedBytes);

      var similarity = await compareImages(
        src1: storedImage,
        src2: capturedImage,
        algorithm: EuclideanColorDistance(),
      );

      if (similarity != null) {
        if (similarity >= 100) {
          // Photos match, trigger action
          print('Photos match!');
          // Add your action code here
        } else {
          print('Photos do not match!');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Match App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            storedPhoto != null
                ? Image.file(
              storedPhoto!,
              height: 200,
            )
                : Text('No stored photo'),
            SizedBox(height: 20),
            capturedPhoto != null
                ? Image.file(
              capturedPhoto!,
              height: 200,
            )
                : Text('No captured photo'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectPhoto,
              child: Text('Select stored photo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: capturePhoto,
              child: Text('Capture photo'),
            ),
            SizedBox(height: 20),
            isMatching ? Text('Photos Match') : Text('Photos Do Not Match'),
          ],
        ),
      ),
    );
  }
}
