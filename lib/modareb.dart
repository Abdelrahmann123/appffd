import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled17/payments.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayTrainersPage extends StatefulWidget {
  @override
  _DisplayTrainersPageState createState() => _DisplayTrainersPageState();
}

class _DisplayTrainersPageState extends State<DisplayTrainersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  // دالة لفتح الروابط
  _launchURL(String? url) async {
    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Display Trainers'),
        actions: [],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    child: TextFormField(
                      controller: _searchController,
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
                      style: TextStyle(color: Colors.black),
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
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('approved_trainers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var trainers = snapshot.data!.docs;

                // Filter trainers based on the search input
                var filteredTrainers = trainers.where((trainer) {
                  var trainerName = trainer['name'].toString().toLowerCase();
                  var searchQuery = _searchController.text.toLowerCase();
                  return trainerName.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredTrainers.length,
                  itemBuilder: (context, index) {
                    var trainer =
                    filteredTrainers[index].data()! as Map<String, dynamic>;
                    return TrainerCard(
                      trainer: trainer,
                      // تمرير دالة فتح الروابط كوسيطة
                      launchURL: _launchURL,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class TrainerCard extends StatelessWidget {
  final Map<String, dynamic> trainer;
  final Function(String?) launchURL;

  TrainerCard({required this.trainer, required this.launchURL});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainerDetailsScreen(trainer: trainer),
          ),
        );
      },
      child: Card(
        color: Colors.grey[300],
        elevation: 5,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trainer['profileImage'] != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      trainer['profileImage'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Text(
                'Name: ${trainer['name']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Experience: ${trainer['experience']} years',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Age: ${trainer['age']}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Sport: ${trainer['sport']}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (trainer['linkedin'] != null)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.linkedin),
                      onPressed: () {
                        launchURL(trainer['linkedin']);
                      },
                    ),
                  if (trainer['youtube'] != null)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.youtube),
                      onPressed: () {
                        launchURL(trainer['youtube']);
                      },
                    ),
                  if (trainer['instagram'] != null)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.instagram),
                      onPressed: () {
                        launchURL(trainer['instagram']);
                      },
                    ),
                  if (trainer['twitter'] != null)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.twitter),
                      onPressed: () {
                        launchURL(trainer['twitter']);
                      },
                    ),
                  if (trainer['facebook'] != null)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.facebook),
                      onPressed: () {
                        launchURL(trainer['facebook']);
                      },
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

class TrainerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trainer;

  TrainerDetailsScreen({required this.trainer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trainer['profileImage'] != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    trainer['profileImage'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      'Name: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trainer['name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      'Experience: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trainer['experience']} years',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      'Age: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trainer['age']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      'Sport: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trainer['sport']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Buy();
                        },
                      ),
                    );
                  },
                  child: Text('Subscribe'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}