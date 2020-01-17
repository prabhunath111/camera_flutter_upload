import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  static File _image;
  String _imageAsBase64;
  String status = '';
  static final String uploadEndPoint = 'http://192.168.29.152:3000/postimage';
  String errorMessage = 'Error Uploading Image';

  Future getImage(bool isCamera) async {

    File image;

    if (isCamera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    List<int> imageBytes = image.readAsBytesSync();
//    print('imageBytes $imageBytes');

    String base64Image = base64Encode(imageBytes);

    print('base64Image $base64Image');
//    print("You selected gallery image : " + image.path);

    setState(() {
      _image = image;
      _imageAsBase64 = base64Image;
    });
  }


  setStatus(String message){
    setState(() {
      status = message;
      print(status);
    });
  }

  startUpload() {
    setStatus('Uploading Image');
    if (_image == null) {
      setStatus(errorMessage);
      return;
    }

    String fileName = _image.path
        .split('/')
        .last;
    upload(fileName);
  }
  upload(String fileName){
    http.post(uploadEndPoint,body: {
      "image": _image,
    }).then((result){
      setStatus(result.statusCode == 200 ? result.body: errorMessage);
    }).catchError((error){
      setStatus(error);
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Picker'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.insert_drive_file),
                onPressed: () {
                  getImage(false);
                },
              ),
              SizedBox(height: 10.0),
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  getImage(true);
                },
              ),
              _image == null
                  ? Container()
                  : Image.file(
                      _image,
                      height: 300.0,
                      width: 300.0
                    ),
              SizedBox(height: 30.0,),
              RaisedButton(
                child: Text('Upload Image'),
                elevation: 2.0,
                color: Colors.lightBlue,
                onPressed: (){
                  startUpload();
                print('upload image button clicked!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
