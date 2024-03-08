import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled17/screens/home_page.dart';

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;

  String _gender = 'Male'; // Default 'Male'

  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _loading = false;
  String _imageUrl = ''; // Variable to store the image URL

  TextEditingController _dayController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = TextEditingController();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // Remove the call to uploadImage here, it will be called when saving the profile
      }
    });
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      try {
        String userId = _auth.currentUser!.uid;
        Reference ref = _storage.ref().child('profile_images/$userId.jpg');
        UploadTask uploadTask = ref.putFile(_image!);
        await uploadTask.whenComplete(() => null);
        String downloadUrl = await ref.getDownloadURL();

        // Save the download URL to the _imageUrl variable
        _imageUrl = downloadUrl;

        // Print the image URL for verification
        print('Image uploaded. Download URL: $_imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> saveProfile() async {
    try {
      // Show Loading
      setState(() {
        _loading = true;
      });

      await uploadImage();

      // Save other profile data to Firestore
      String userId = _auth.currentUser!.uid;
      await _firestore.doc('users/$userId').set({
        'name': _nameController.text,
        'city': _cityController.text,
        'gender': _gender,
        'birthdate':
        '${_dayController.text}/${_monthController.text}/${_yearController.text}',
        'phone': _phoneController.text,
        'profileImageUrl': _imageUrl,
      });

      print('Profile saved successfully.');

      // Navigate to HomePage after successful save
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      // Hide Loading
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dayController.text = pickedDate.day.toString();
        _monthController.text = pickedDate.month.toString();
        _yearController.text = pickedDate.year.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(
                  Icons.camera_alt,
                  size: 40,
                )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (String? value) {
                setState(() {
                  _gender = value!;
                });
              },
              items: ['Male', 'Female']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
                  .toList(),
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dayController,
                        decoration: InputDecoration(labelText: 'Day'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _monthController,
                        decoration: InputDecoration(labelText: 'Month'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveProfile();
              },
              child: _loading
                  ? CircularProgressIndicator()
                  : Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
