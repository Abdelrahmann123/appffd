import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled17/payments.dart';

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
        actions: [

        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // تحديد المسافات من اليمين واليسار والأعلى والأسفل
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
                    var trainer = filteredTrainers[index].data()! as Map<String, dynamic>;
                    return TrainerCard(
                      trainer: trainer,
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

  TrainerCard({required this.trainer});

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
                CircleAvatar(
                  backgroundImage: NetworkImage(trainer['profileImage']),
                  radius: 50,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trainer['profileImage'] != null)
            Image.network(
              trainer['profileImage'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 20),
          Text('Name: ${trainer['name']}'),
          Text('Experience: ${trainer['experience']} years'),
          Text('Age: ${trainer['age']}'),
          Text('Sport: ${trainer['sport']}'),
          // Subscription button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
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
        ],
      ),
    );
  }
}
