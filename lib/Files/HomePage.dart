import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'Loginpage.dart';
import 'Newtask.dart';

class Homepage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Homepage({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CollectionReference _appCollection =
  FirebaseFirestore.instance.collection('notekeeper');

  late CameraController _cameraController;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  void deleteApp(String upid) {
    _appCollection.doc(upid).delete();
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      // Handle the case when no cameras are available
      print('No cameras available');
      return;
    }

    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(source: ImageSource.camera);
      setState(() {
        if (pickedImage != null) {
          _imageFile = File(pickedImage.path);
        }
      });
      await uploadPhoto();
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> uploadPhoto() async {
    if (_imageFile != null) {
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('photos/$taskId.jpg');
      final uploadTask = storageRef.putFile(_imageFile!);

      try {
        await uploadTask.whenComplete(() {
          print('Photo uploaded successfully');
        });
      } catch (e) {
        print('Failed to upload photo: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void toggleCamera() {
    setState(() {
      if (_imageFile != null) {
        _imageFile = null;
      } else {
        pickImage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF496ACE)),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: 'User Successfully Logged Out');

              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout),
            color: Color(0xFF496ACE),
          ),

        ],
      ),
      floatingActionButton: SizedBox(
        height: 65.0,width: 60,
        child: RawMaterialButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewTaskScreen()),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 2.0,
          fillColor: Colors.white,
          child: Icon(Icons.add, color: Color(0xFF496ACE),size: 30,),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Add Your Notes",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (_) {
                toggleCamera();
              },
              child: _imageFile != null
                  ? Image.file(_imageFile!) // Display the captured photo
                  : StreamBuilder<QuerySnapshot>(
                stream: _appCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final appSnapshots = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: appSnapshots.length,
                      itemBuilder: (context, index) {
                        final appData = appSnapshots[index].data() as Map<String, dynamic>;
                        final appId = appSnapshots[index].id;

                        return Dismissible(
                          key: Key(appId),
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) {
                            deleteApp(appId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appData['title'],
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              appData['note'].toString(),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/Update', arguments: {
                                          'title': appData['title'],
                                          'note': appData['note'],
                                          'id': appId,
                                        });
                                      },
                                      icon: const Icon(Icons.edit,color: Colors.grey,),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Add New Tasks',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
