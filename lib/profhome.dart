import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:untitled17/screens/home_page.dart';
import 'package:untitled17/screens/side_menu.dart';

import 'fav.dart';
import 'notif.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfilePage(), // تحديد صفحة البداية للتطبيق
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userData = userDoc.data() as Map<String, dynamic>;
    });
  }

  // Add a function to handle the edit button press
  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData),
      ),
    ).then((value) {
      // Refresh the data after returning from the EditProfilePage
      if (value != null && value) {
        fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        // Add the edit icon to the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userData['profileImageUrl'] ?? ''),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text('الاسم'),
                subtitle: Text(userData['name'] ?? ''),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('رقم الهاتف'),
                subtitle: Text(userData['phone'] ?? ''),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('تاريخ الميلاد'),
                subtitle: Text(userData['birthdate'] ?? ''),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('المحافظة'),
                subtitle: Text(userData['city'] ?? ''),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xffF5F5F5),
        color: Color.fromARGB(255, 209, 212, 217),
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FavoritesPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotificationsPage(),
              ),
            );
          } else if (index == 3) {
            // Do nothing since we are already on Profile page
          }
        },
        index: 3, // تحديد التحديد عند الزر الخاص بالحساب
        items: [
          Icon(
            Icons.home,
            color: Colors.black,
          ),
          Icon(
            Icons.favorite,
            color: Colors.black,
          ),
          Icon(
            Icons.notifications,
            color: Colors.black,
          ),
          Icon(
            Icons.account_circle_rounded,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _birthdateController =
        TextEditingController(text: widget.userData['birthdate']);
    _cityController = TextEditingController(text: widget.userData['city']);
  }

  Future<void> _saveChanges() async {
    try {
      // Save updated profile data to Firestore
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.doc('users/$userId').update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'birthdate': _birthdateController.text,
        'city': _cityController.text,
      });

      // Return true to indicate successful save
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving changes: $e');
      // Return false to indicate unsuccessful save
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: 'Birthdate'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null && pickedDate != DateTime.now()) {
                  setState(() {
                    _birthdateController.text =
                    '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                  });
                }
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}