import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(NutritionApp());

class NutritionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Nutritionist',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: NutritionHomePage(),
    );
  }
}

class NutritionHomePage extends StatefulWidget {
  @override
  _NutritionHomePageState createState() => _NutritionHomePageState();
}

class _NutritionHomePageState extends State<NutritionHomePage> {
  File? _image;
  bool _loading = false;
  String _response = '';
  final TextEditingController _promptController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
    });

    String defaultPrompt = """Read the text
    """;

    String inputPrompt =
        _promptController.text.isEmpty ? defaultPrompt : _promptController.text;

    try {
      String fileName = _image!.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(_image!.path, filename: fileName),
        "prompt": inputPrompt,
      });

      Response response = await Dio().post(
        //'http://127.0.0.1:5000/analyze',
        'http://10.0.2.2:5000/analyze',
        data: formData,
      );

      setState(() {
        _response = response.data['response'];
      });
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error uploading image', e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _image = null;
      _response = '';
      _promptController.clear();
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Nutrionist'),
      ),
      body: _loading
          ? Center(
              child: SpinKitCircle(
                color: Colors.green,
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  _image == null
                      ? Text(
                          'No image selected.',
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                20.0), // Adjust the radius as needed
                            child: Image.file(
                              _image!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getImage,
                    child: Text('Choose an Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 189, 35, 255),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 199, 20),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _clear,
                    child: Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _response.isEmpty
                      ? Container()
                      : Text(
                          'Text:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  SizedBox(height: 10),
                  _response.isEmpty
                      ? Container()
                      : SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              _response,
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  SizedBox(height: 40),
                  Divider(),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/leftlogo.png', // Ensure this asset exists
                          height: 50,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Developed by Sindhu and team',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Department of CSE ',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'K S Institute of Technology',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
