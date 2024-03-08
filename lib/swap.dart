import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddProductPage(),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  PickedFile? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = pickedFile;
    });
  }

  Future<void> _uploadData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;

        if (
        _nameController.text.isEmpty ||
            _descriptionController.text.isEmpty ||
            _addressController.text.isEmpty ||
            _phoneController.text.isEmpty ||
            _pickedImage == null
        ) {
          // Show an error message if any of the required fields is empty
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all fields and pick an image'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Get the reference to the Firebase Storage
        final Reference storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now()}.jpg');

        // Upload the image to Firebase Storage
        await storageRef.putFile(File(_pickedImage!.path));

        // Get the URL of the uploaded image
        final String imageUrl = await storageRef.getDownloadURL();

        // Add product details to Firestore
        await _firestore.collection('products').add({
          'uid': uid,
          'name': _nameController.text,
          'description': _descriptionController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'imageUrl': imageUrl, // Add the image URL to Firestore
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to DisplayProductsPage after successful upload
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisplayProductsPage()),
        );
      }
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading data: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error uploading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add sports tool'),
      ),
      backgroundColor: Colors.white, // تغيير خلفية الصفحة
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_pickedImage != null)
                Image.file(
                  File(_pickedImage!.path),
                  height: 150,
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadData,
                child: Text('Add tool'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayProductsPage extends StatefulWidget {
  @override
  _DisplayProductsPageState createState() => _DisplayProductsPageState();
}

class _DisplayProductsPageState extends State<DisplayProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display sports tools'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var products = (snapshot.data as QuerySnapshot?)?.docs ?? [];

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index].data() as Map<String, dynamic>;
              return Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product['imageUrl'] != null)
                      Image.network(
                        product['imageUrl'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Text('Name: ${product['name']}'),
                    Text('Description: ${product['description']}'),
                    Text('Address: ${product['address']}'),
                    Text('Phone: ${product['phone']}'),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}