import 'package:flutter/material.dart';
import 'package:untitled17/screens/vod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaygroundDetailsPage extends StatelessWidget {
  final Map<String, dynamic> playgroundData;

  const PlaygroundDetailsPage({Key? key, required this.playgroundData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  image: NetworkImage(playgroundData['imageUrl'][0]),
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
                  _buildDetail('Lockers:', playgroundData['lockers']),
                  _buildDetail('Open Time:', playgroundData['openTime']),
                  _buildDetail('Close Time:', playgroundData['closeTime']),
                  SizedBox(height: 16),
                  _buildLocationButton('Location', playgroundData['location']),
                  SizedBox(height: 16),
                  _buildDetail('Sport Type:', playgroundData['type']),
                  SizedBox(height: 16),
                  _buildDetail(
                      'Description:', playgroundData['stadiumDetails']),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VodafonePlayground()),
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
    if (data == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            data,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(String label, String location) {
    return TextButton(
      onPressed: () {
        _launchGoogleMaps(location);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  _launchGoogleMaps(String location) async {
    final url = location;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}