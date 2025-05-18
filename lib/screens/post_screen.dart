import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _uploadPost() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please complete all fields")));
      return;
    }
    // TODO: Upload logic (Firebase Firestore + Storage)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Post uploaded successfully!")));
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Post Title"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Post Description"),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Center(child: Text("Tap to select image")),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadPost,
                child: Text("Upload Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
