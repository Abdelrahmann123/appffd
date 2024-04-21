import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/profhome.dart';
import 'package:untitled17/screens/home_page.dart';
import 'package:untitled17/screens/side_menu.dart';

import 'notif.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color appBarColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Color.fromARGB(255, 221, 225, 231);
    Color backgroundColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[900]!
        : Color(0xffF5F5F5);
    Color textColor =
    themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    Color backButtonColor =
    themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.grey[800]
            : Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Favorites', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: backButtonColor),
      ),
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Colors.grey[900]
          : Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Add your widgets here
                    SizedBox(height: 20),
                  ],
                ),
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
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotificationsPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          }
        },
        index: 1, // Set the initial index to the notifications tab
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