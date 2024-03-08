import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'BookingScreen.dart';

class PlaygroundDetailsPage extends StatelessWidget {
  final Map<String, dynamic> playgroundData;

  const PlaygroundDetailsPage({Key? key, required this.playgroundData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if playgroundData is not null and contains data
    if (playgroundData == null || playgroundData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('No data available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Playground Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(playgroundData['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  _buildDetail('Name:', playgroundData['name']),
                  _buildDetail('Price:', playgroundData['price']),
                  _buildDetail('Governorate:', playgroundData['governorate']),
                  _buildDetail('City:', playgroundData['city']),
                  _buildDetail('Street:', playgroundData['street']),
                  SizedBox(height: 16),
                  _buildLocationButton('Location', playgroundData['location']),
                  SizedBox(height: 16),
                  _buildDetail('Sport Type:', playgroundData['sportType']),
                  SizedBox(height: 16),
                  _buildDetail('Description:', playgroundData['description']),
                  SizedBox(height: 16),

                  // Booking Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InteractiveCalendarScreen(),
                        ),
                      );
                    },
                    child: Text('Book Playground'),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, dynamic data) {
    // Check if data is not null before displaying
    if (data == null) {
      return Container(); // Return an empty container or customize as needed
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: Text(
            '$data',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationButton(String label, String location) {
    return GestureDetector(
      onTap: () {
        _launchGoogleMaps(location);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _launchGoogleMaps(String location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
