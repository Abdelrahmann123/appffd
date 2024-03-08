import 'package:flutter/material.dart';


import 'package:carousel_slider/carousel_slider.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';

import 'package:untitled17/screens/side_menu.dart';

import '../events.dart';

import '../modareb.dart';
import '../playground.dart';
import '../pro.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double xoffset = 0;
  double yoffset = 0;

  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // عند الضغط على زر الرجوع
        // قم بإغلاق التطبيق
        SystemNavigator.pop();
        return true; // ترجيع قيمة true للسماح بالعملية
      },
      child: Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Color(0xffF5F5F5),
          color: Color.fromARGB(255, 209, 212, 217),
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {});
          },
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
        drawer: SideMenu(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Transform.rotate(
                    origin: Offset(30, -60),
                    angle: 2.4,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 65,
                        top: 40,
                      ),
                      height: screenSize.height * 0.6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(88),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          colors: [
                            Color.fromARGB(255, 134, 140, 143),
                            Color.fromARGB(255, 209, 212, 217),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        AppBar(
                          backgroundColor: Color.fromARGB(255, 221, 225, 231),
                          iconTheme: IconThemeData.fallback(),
                          title: Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: CircleAvatar(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage('images/spooooortttt.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        ////0000000000000000000000000000000000000000000000000000000000000000000000
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Slider(),
                              SizedBox(
                                height: 25,
                              ),
                              Text(
                                "What are you looking for?",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EventScreen();
                                          },
                                        ),
                                      );
                                    },
                                    child: NewPadding(
                                      image: 'images/Fitness_couple_running_vector_image_on_VectorStock-removebg-preview.png',
                                      text: 'Events',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Playground();
                                          },
                                        ),
                                      );
                                    },
                                    child: NewPadding(
                                      image: 'images/3a523d32-8218-4bb6-b3bb-a02b56bd7e58-removebg-preview.png',
                                      text: 'Playground',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DisplayTrainersPage();
                                          },
                                        ),
                                      );
                                    },
                                    child: NewPadding(
                                      image: 'images/WhatsApp_Image_2023-12-13_at_10.33.02_PM-removebg-preview.png',
                                      text: 'Trainers',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DisplayProductsPage();
                                          },
                                        ),
                                      );
                                    },
                                    child: NewPadding(
                                      image: 'images/ea819bf4-ebaf-49d0-9acd-60d8f0ee9aad-removebg-preview.png',
                                      text: 'Swap',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewPadding extends StatelessWidget {
  final String image;
  final String text;

  const NewPadding({
    Key? key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                width: 83,
                height: 25,
                color: Color(0xffF5F5F5),
                margin: EdgeInsets.only(top: 125, left: 34, bottom: 25),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
            ],
          ),
        ]);
  }
}

class Slider extends StatelessWidget {
  const Slider({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageAssets = [
      "images/events_home.jpeg",
      "images/off0.jpeg",
      "images/off.jpeg",
      "images/events.jpeg",
    ];
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 206.0,
          viewportFraction: 1,
          autoPlay: true,
          autoPlayCurve: Curves.easeInOutCubicEmphasized,
          autoPlayAnimationDuration: Duration(seconds: 1),
        ),
        items: imageAssets.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage(i),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: 110,
                          left: 24,
                          top: 35,
                        ),
                        width: 209,
                        height: 72,
                        child: Text(
                          "\n 50% Off",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}