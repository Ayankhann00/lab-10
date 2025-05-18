import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class Post {
  String title;
  String description;
  File? image;

  Post({required this.title, required this.description, this.image});
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Post> posts = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Social Media',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FeedScreen(
        posts: posts,
        onDelete: (index) {
          setState(() {
            posts.removeAt(index);
          });
        },
        onUpdate: (index, updatedPost) {
          setState(() {
            posts[index] = updatedPost;
          });
        },
        onAdd: (newPost) {
          setState(() {
            posts.add(newPost);
          });
        },
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  final List<Post> posts;
  final Function(int) onDelete;
  final Function(int, Post) onUpdate;
  final Function(Post) onAdd;

  FeedScreen({
    required this.posts,
    required this.onDelete,
    required this.onUpdate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newPost = await Navigator.push<Post>(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScreen(),
                ),
              );
              if (newPost != null) {
                onAdd(newPost);
              }
            },
          )
        ],
      ),
      body: posts.isEmpty
          ? Center(child: Text('No posts yet!'))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    title: Text(post.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(post.description),
                    leading: post.image != null
                        ? GestureDetector(
                            onLongPress: () async {
                              await _downloadImage(context, post.image!);
                            },
                            child: Image.file(
                              post.image!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final updatedPost = await Navigator.push<Post>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateScreen(post: post),
                              ),
                            );
                            if (updatedPost != null) {
                              onUpdate(index, updatedPost);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(context, () {
                              onDelete(index);
                              Navigator.pop(context); // Close dialog
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onYes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('No')),
          ElevatedButton(onPressed: onYes, child: Text('Yes')),
        ],
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context, File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = imageFile.path.split('/').last;
      final newFile = await imageFile.copy('${appDir.path}/$fileName');

      // Show snackbar or toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image')),
      );
    }
  }
}

class UploadScreen extends StatefulWidget {
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _uploadPost() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    final newPost = Post(title: title, description: desc, image: _selectedImage);
    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Post Title'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Post Description'),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text('Select Image'),
            ),
            SizedBox(height: 12),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : SizedBox.shrink(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateScreen extends StatefulWidget {
  final Post post;

  UpdateScreen({required this.post});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  File? _updatedImage;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _updatedImage = widget.post.image;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _updatedImage = File(pickedFile.path);
      });
    }
  }

  void _updatePost() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    final updatedPost =
        Post(title: title, description: desc, image: _updatedImage);
    Navigator.pop(context, updatedPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Post Title'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Post Description'),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text('Change Image'),
            ),
            SizedBox(height: 12),
            _updatedImage != null
                ? Image.file(_updatedImage!, height: 150)
                : SizedBox.shrink(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updatePost,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
