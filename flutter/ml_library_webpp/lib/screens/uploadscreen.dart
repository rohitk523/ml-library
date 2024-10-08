// screens/upload_screen.dart (or leave it in main.dart as per your preference)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _image;
  Uint8List? _webImage; // To hold the web image bytes
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Handle web image differently
      if (kIsWeb) {
        // Read the bytes for the web platform
        Uint8List webImage =
            await pickedFile.readAsBytes(); // Correctly await the bytes
        setState(() {
          _image = pickedFile;
          _webImage = webImage; // Store the bytes in the state
        });
      } else {
        // For non-web platforms
        setState(() {
          _image = pickedFile;
        });
      }
    }
  }

  // Function to upload the image to FastAPI backend
  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://127.0.0.1:8000/predict_digit'), // Replace with your URL
      );

      if (kIsWeb) {
        // Web upload using bytes
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webImage!,
          filename: 'upload.png', // Name the file
        ));
      } else {
        // Mobile/desktop upload using file path
        request.files
            .add(await http.MultipartFile.fromPath('file', _image!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        var responseData = jsonDecode(responseBody.body);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: responseData['digit']),
          ),
        );
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digit Recognition")),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Text("No image selected.")
                      : kIsWeb
                          ? _webImage != null
                              ? Image.memory(_webImage!, height: 200)
                              : Text("Failed to load web image.")
                          : Image.file(File(_image!.path), height: 200),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Pick Image"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text("Upload Image"),
                  ),
                ],
              ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String result;

  ResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: Text(
          "The digit is: $result",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
