import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

void main() => runApp(MaterialApp(
  home: ProfilePage(),
));
