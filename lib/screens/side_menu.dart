import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled17/screens/setting.dart';

import '../profhome.dart';
import 'betriner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckUserPage(),
    );
  }
}

class CheckUserPage extends StatelessWidget {
  const CheckUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUser(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.data != null && snapshot.data!) {
            // المستخدم مسجل بياناته في كولكشن المدربين في فايربيس
            return const NewPage();
          } else {
            // المستخدم ليس لديه بيانات في كولكشن المدربين في فايربيس
            return  TrainerResPage();
          }
        }
      },
    );
  }

  Future<bool> checkUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // قم بفحص ما إذا كان لديك بيانات للمستخدم في كولكشن المدربين في فايربيس
        DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection('trainers').doc(user.uid).get();

        // إذا كان هناك بيانات للمستخدم، فهو مسجل في كولكشن المدربين
        return userData.exists;
      }

      return false;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }
}
class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Page'),
      ),
      body: const Center(
        child: Text('This is a new page.'),
      ),
      drawer: const SideMenu(),
    );
  }
}




class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 55, 55, 55),
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(
                'SPORTIFY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'images/spooooortttt.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 55, 55, 55),
              ),
            ),
            _buildMenuItem('Be a Trainer', Icons.group_add, () async {
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                // قم بفحص ما إذا كان لديك بيانات للمستخدم في كولكشن المدربين في فايربيس
                DocumentSnapshot userData =
                await FirebaseFirestore.instance.collection('trainers').doc(user.uid).get();

                // إذا لم يكن هناك بيانات، فقم بفتح صفحة التسجيل
                if (!userData.exists) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  TrainerResPage()),
                  );
                } else {
                  // إذا كانت هناك بيانات، فقم بفتح الصفحة الجديدة
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewPage()),
                  );
                }
              }
            }),
            _buildMenuItem('Setting', Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }),
            _buildMenuItem('Profile', Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfilePage()),
              );
            }),
            _buildMenuItem('Search', Icons.search, () {}),
            _buildMenuItem('Saved', Icons.bookmark, () {}),
            _buildMenuItem('Favorites', Icons.favorite, () {}),
            const Divider(
              color: Colors.white,
            ),
            _buildMenuItem('Log out', Icons.logout, () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Page'),
      ),
      body: const Center(
        child: Text('Setting Page Content'),
      ),
    );
  }
}
// ... Other page classes ...
