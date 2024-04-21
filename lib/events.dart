
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddEventScreen.dart';


class EventCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const EventCard({Key? key, required this.data}) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  int subscribersCount = 0;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _getSubscribersCount();
    _checkIfSubscribed();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? images = (widget.data['images'] as List<dynamic>?)?.map((
        e) => e as String).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: widget.data),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images != null && images.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.network(
                        images[index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            Text(
              'Event Type: ${widget.data['eventType']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'distance: ${widget.data['distance']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'fee: ${widget.data['fee']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'insurance: ${widget.data['insurance']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isSubscribed ? null : () =>
                      _subscribeToEvent(context, widget.data),
                  child: Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                ),
                SizedBox(width: 8),
                Text(
                  'Subscribers: $subscribersCount',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getSubscribersCount() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
        'event_subscribers_${widget.data['eventId']}').get();
    setState(() {
      subscribersCount = snapshot.docs.length;
    });
  }

  Future<void> _checkIfSubscribed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
        'event_subscribers_${widget.data['eventId']}').where(
        'userId', isEqualTo: userId).get();
    setState(() {
      isSubscribed = snapshot.docs.isNotEmpty;
    });
  }

  void _subscribeToEvent(BuildContext context, Map<String, dynamic> eventData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String age = '';
        String gender = '';
        String phone = '';

        return AlertDialog(
          title: Text('Subscribe to Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  age = value;
                },
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                onChanged: (value) {
                  gender = value;
                },
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                onChanged: (value) {
                  phone = value;
                },
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (name.isEmpty || age.isEmpty || gender.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                if (int.tryParse(age) == null || int.tryParse(age)! < 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Age must be a number and at least 16')),
                  );
                  return;
                }

                if (!phone.startsWith('01')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Phone number must start with 01')),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Handle the case where the user is not logged in
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please log in to subscribe to the event')),
                  );
                  Navigator.of(context).pop(); // Close dialog
                  return;
                }

                final userId = user.uid;

                // Check if the user is already subscribed to this event
                final QuerySnapshot existingSubscription = await FirebaseFirestore.instance
                    .collection('event_subscribers_${eventData['eventId']}')
                    .where('userId', isEqualTo: userId)
                    .get();

                if (existingSubscription.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You are already subscribed to this event!')),
                  );
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  // Save subscriber data to a new collection for event subscriptions
                  Map<String, dynamic> subscriberData = {
                    'name': name,
                    'age': age,
                    'gender': gender,
                    'phone': phone,
                    'userId': userId,
                  };

                  // Use event ID and user ID as a unique identifier for the subscription
                  final CollectionReference eventSubscribersCollection = FirebaseFirestore
                      .instance.collection('event_subscribers_${eventData['eventId']}');
                  eventSubscribersCollection.add(subscriberData).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Subscribed to the event successfully!')),
                    );
                    Navigator.of(context).pop(); // Close dialog

                    // Update subscribers count after subscribing
                    _getSubscribersCount();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to subscribe to the event: $error')),
                    );
                  });

                  // Refresh the EventScreen after subscription
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => EventScreen()),
                  );
                }
              },
              child: Text('Subscribe'),
            ),
          ],
        );
      },
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['images'] != null && (event['images'] as List).isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (event['images'] as List).length,
                  itemBuilder: (context, index) {
                    String imageUrl = event['images'][index];
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text('Event Name: ${event['eventName']}'),
            Text('Status: ${event['status']}'),
            Text('Age Range: ${event['ageRangeFrom']}-${event['ageRangeTo']}'),
            Text('Description: ${event['description']}'),
            if (event['distance'] != null)
              Text('Distance: ${event['distance']}'),
            if (event['date'] != null)
              Text('Date: ${event['date']}'),
            Text('Event Type: ${event['eventType']}'),
            Text('Fee: ${event['fee']}'),
            if (event['haveBike'] != null)
              Text('Have Bike: ${event['haveBike']}'),
            Text('Insurance: ${event['insurance']}'),
          ],
        ),
      ),
    );
  }
}

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SearchBar(),
              SizedBox(height: 20),
              EventList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('accepted_events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final events = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return EventCard(data: event);
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EventScreen(),
  ));
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with your SearchBar implementation
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
    );
  }
}