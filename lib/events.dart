import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color textColor =
    themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          SizedBox(width: 12),
          ClipOval(
            child: Image.asset(
              "images/spooooortttt.png",
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
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
        title: Text('Event', style: TextStyle(color: Colors.white)),
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
                    SearchBar(), // استخدم البحث في الأعلى
                    SizedBox(height: 20),
                    EventCard(
                      image: 'images/events.png',
                      title: 'Skating Event',
                      date: '30 Jan 2023',
                      location: 'Cairo, Shoubra',
                      onBookPressed: () {
                        // إضافة الإجراء الذي يحدث عند الضغط على زر الحجز
                        print('Book button pressed!');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: CircularMenu(
                alignment: Alignment.bottomRight,
                toggleButtonColor: Colors.blue,
                items: [
                  CircularMenuItem(
                    icon: Icons.add_outlined,
                    color: Colors.green,
                    onTap: () {
                      // عشان اضيف ايفينت
                    },
                  ),
                  CircularMenuItem(
                    icon: Icons.favorite_sharp,
                    color: Colors.red,
                    onTap: () {
                      // صفحة الحاجات الللي سيفتها او عملتلها لاف
                    },
                  ),
                  CircularMenuItem(
                    icon: Icons.history,
                    color: Colors.brown,
                    onTap: () {
                      // صفحة الايفينتات القديمه
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String image;
  final String title;
  final String date;
  final String location;
  final VoidCallback? onBookPressed; // الإجراء عند الضغط على زر الحجز

  const EventCard({
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    this.onBookPressed, // زر الحجز اختياري
    Key? key,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPressed = !_isPressed;
        });
      },
      child: Card(
        elevation: _isPressed ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: _isPressed
                    ? Matrix4.translationValues(0, -10, 0)
                    : Matrix4.identity(),
                child: Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.date,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.location,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  if (_isPressed) // عشان الضغط على الايفينت
                    SizedBox(height: 8),
                  if (_isPressed)
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Subscribe'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
