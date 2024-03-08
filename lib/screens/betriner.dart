import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TrainerResPage extends StatefulWidget {
  @override
  _TrainerResPageState createState() => _TrainerResPageState();
}

class _TrainerResPageState extends State<TrainerResPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  String _selectedSport = 'Football'; // Default sport

  File? _profileImage;
  File? _idImage;
  List<File?> _certificatesImages = List.generate(8, (index) => null);

  Widget _buildUploadButton(String buttonText, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // Change the button color
        onPrimary: Colors.white, // Change the text color
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _idImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCertificateImages() async {
    List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _certificatesImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _submitData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Check if the user has already submitted data
        DocumentSnapshot userData = await _firestore.collection('trainers').doc(user.uid).get();

        if (!userData.exists) {
          // Upload images to Firebase Storage
          String profileImageUrl = await _uploadImage(_profileImage, 'profile_images');
          String idImageUrl = await _uploadImage(_idImage, 'id_images');
          List<String> certificatesImageUrls = await Future.wait(
            _certificatesImages
                .map((image) => _uploadImage(image, 'certificates_images'))
                .toList(),
          );

          // Save trainer data to Firestore with acceptance status as 'Pending'
          await _firestore.collection('trainer_requests').doc(user.uid).set({
            'profileImage': profileImageUrl,
            'name': _nameController.text,
            'age': int.parse(_ageController.text),
            'address': _addressController.text,
            'experience': int.parse(_experienceController.text),
            'sport': _selectedSport,
            'idImage': idImageUrl,
            'certificatesImages': certificatesImageUrls,
            'status': 'Pending', // Add a field to track the acceptance status
          });

          // Navigate to a new page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReceivingRequests(), // Replace NewPage() with the actual page you want to navigate to.
            ),
          );
        } else {
          print('User has already submitted data.');
          // You can navigate to another page or show a message indicating that the user has already submitted data.
        }
      }
    } catch (e) {
      print('Error submitting data: $e');
      // Handle error (show error message, etc.)
    }
  }

  Future<String> _uploadImage(File? image, String folder) async {
    try {
      if (image != null) {
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child('$folder/$imageName');
        UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);
        return await storageReference.getDownloadURL();
      } else {
        throw Exception('Image file is null.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Resources'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUploadButton('Pick Profile Image', _pickProfileImage),
              if (_profileImage != null) Image.file(_profileImage!),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              DropdownButton<String>(
                value: _selectedSport,
                items: ['Football', 'Swimming', 'Badminton', 'Gym', 'Combat Games']
                    .map((sport) => DropdownMenuItem<String>(
                  value: sport,
                  child: Text(sport),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSport = value!;
                  });
                },
              ),
              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Experience (years)'),
              ),
              _buildUploadButton('Pick ID Image', () => _pickImage(ImageSource.gallery)),
              if (_idImage != null) Image.file(_idImage!),
              _buildUploadButton('Pick Certificates Images', _pickCertificateImages),
              for (int i = 0; i < _certificatesImages.length; i++)
                if (_certificatesImages[i] != null) Image.file(_certificatesImages[i]!),
              _buildUploadButton('Submit', _submitData),
            ],
          ),
        ),
      ),
    );
  }
}

class Follower {
  final String name;
  final String image;

  Follower({required this.name, required this.image});
}

class ReceivingRequests extends StatefulWidget {
  @override
  _ReceivingRequestsState createState() => _ReceivingRequestsState();
}

class _ReceivingRequestsState extends State<ReceivingRequests> {
  List<Follower> followers = [
    Follower(name: 'Follower 1', image: 'assets/icon.jpeg'),
    Follower(name: 'Follower 2', image: 'assets/icon.jpeg'),
    Follower(name: 'Follower 3', image: 'assets/icon.jpeg'),
    Follower(name: 'Follower 4', image: 'assets/icon.jpeg'),
  ];

  List<Follower> acceptedFollowers = [];
  List<Follower> rejectedFollowers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 212, 217),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Receiving Requests'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/logo.jpeg'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final follower = followers[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(follower.image),
            ),
            title: Text(follower.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      followers.removeAt(index);
                      acceptedFollowers.add(follower);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {

                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(follower.name),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Age: 25'),
                              Text('Address: Street, City'),
                              Text('Phone Number: 011000000'),
                              // هنا لو هنضيف اي معلومات تاني
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 209, 212, 217),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Accepted Requests'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          acceptedFollowers.length,
                              (index) {
                            final follower = acceptedFollowers[index];
                            return Dismissible(
                              key: Key(follower.name),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                setState(() {
                                  acceptedFollowers.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${follower.name} has been removed'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(follower.image),
                                ),
                                title: Text(follower.name),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(follower.name),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text('Age: 25'),
                                            Text('Address: Street, City'),
                                            Text('Phone Number: 011000000'),
                                            // هنا لو هنضيف اي معلومات تاني
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Close',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Accepted',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(request['profileImage']),
              radius: 50,
            ),
            SizedBox(height: 10),
            Text(
              'Name: ${request['name']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Age: ${request['age']}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(

              'Experience: ${request['experience']} years',
              style: TextStyle(
                fontSize: 16,

              ),
            ),
            Text(
              'Sport: ${request['sport']}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _acceptRequest(request['userId']); // Implement the accept logic
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Accept button color
                    onPrimary: Colors.white, // Accept button text color
                  ),
                  child: Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _rejectRequest(request['userId']); // Implement the reject logic
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Reject button color
                    onPrimary: Colors.white, // Reject button text color
                  ),
                  child: Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(String userId) {
    // Implement the logic to accept the trainer request
  }

  void _rejectRequest(String userId) {
    // Implement the logic to reject the trainer request
  }
}
