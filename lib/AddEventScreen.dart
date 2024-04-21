import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  List<File> _selectedImages = [];
  String? _selectedEventType;
  String? _phoneNumber;
  String? _eventLocation;
  String? _description;
  String? _ageRangeFrom;
  String? _ageRangeTo;
  bool? _fee;
  bool? _insurance;
  bool? _haveBike;
  double? _distance;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage(
        maxWidth: 800,
        imageQuality: 80,
      );

      if (images != null) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  void _addEventToFirestore() async {
    if (_formKey.currentState!.validate()) {
      CollectionReference events = FirebaseFirestore.instance.collection('events');

      List<String> imageUrls = await _uploadImages(_selectedImages);

      events.add({
        'eventName': _eventLocation,
        'phoneNumber': _phoneNumber,
        'distance': _distance,
        'description': _description,
        'ageRangeFrom': _ageRangeFrom,
        'ageRangeTo': _ageRangeTo,
        'fee': _fee,
        'insurance': _insurance,
        'haveBike': _haveBike,
        'eventType': _selectedEventType,
        'images': imageUrls,
        'userId': FirebaseAuth.instance.currentUser!.uid, // Add current user ID
        'date': DateTime.now(), // Add current date
      }).then((value) {
        print("Event added with ID: ${value.id}");
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages.clear();
        });
      }).catchError((error) {
        print("Failed to add event: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: _selectedImages.isEmpty
                        ? Center(child: Text('Add Image'))
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            width: 150,
                            height: 200,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Event Location',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _eventLocation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  decoration: InputDecoration(
                    labelText: 'Select Event Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value;
                      // Reset the fields when event type changes
                      _ageRangeFrom = null;
                      _ageRangeTo = null;
                      _fee = null;
                      _insurance = null;
                      _haveBike = null;
                      _distance = null;
                    });
                  },
                  items: <String>['Cycling Event', 'Running Event', 'Football Event']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (_selectedEventType == 'Cycling Event' || _selectedEventType == 'Running Event') ...[
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Age Range From',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _ageRangeFrom = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Age Range To',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _ageRangeTo = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          decoration: InputDecoration(
                            labelText: 'Fee',
                            border: OutlineInputBorder(),
                          ),
                          value: _fee,
                          onChanged: (value) {
                            setState(() {
                              _fee = value;
                            });
                          },
                          items: <bool?>[true, false].map<DropdownMenuItem<bool>>(
                                (bool? value) {
                              return DropdownMenuItem<bool>(
                                value: value,
                                child: Text(value == true ? 'Yes' : 'No'),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          decoration: InputDecoration(
                            labelText: 'Insurance',
                            border: OutlineInputBorder(),
                          ),
                          value: _insurance,
                          onChanged: (value) {
                            setState(() {
                              _insurance = value;
                            });
                          },
                          items: <bool?>[true, false].map<DropdownMenuItem<bool>>(
                                (bool? value) {
                              return DropdownMenuItem<bool>(
                                value: value,
                                child: Text(value == true ? 'Yes' : 'No'),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedEventType == 'Cycling Event') ...[
                    SizedBox(height: 20),
                    DropdownButtonFormField<bool>(
                      decoration: InputDecoration(
                        labelText: 'Do you have a bike?',
                        border: OutlineInputBorder(),
                      ),
                      value: _haveBike,
                      onChanged: (value) {
                        setState(() {
                          _haveBike = value;
                        });
                      },
                      items: <bool?>[true, false].map<DropdownMenuItem<bool>>(
                            (bool? value) {
                          return DropdownMenuItem<bool>(
                            value: value,
                            child: Text(value == true ? 'Yes' : 'No'),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ],
                if (_selectedEventType == 'Running Event') ...[
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Distance (in kilometers)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _distance = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addEventToFirestore,
                  child: Text('Add Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
