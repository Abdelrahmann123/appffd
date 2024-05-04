import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscribersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Subscribers'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // استخدم QuerySnapshot هنا
        stream: FirebaseFirestore.instance
            .collection('event_subscribers_null')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // تحقق من وجود البيانات
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No subscribers found.'),
              );
            }

            // قم بتكوين قائمة من الوثائق
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> subscriberData =
                document.data()! as Map<String, dynamic>;
                // تحقق إذا كان المستخدم الحالي هو صاحب الحدث
                if (currentUser != null &&
                    subscriberData['userId'] == currentUser.uid) {
                  // عرض المشتركين فقط إذا كان المستخدم الحالي هو الصاحب
                  return ListTile(
                    title: Text('Name: ${subscriberData['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${subscriberData['phone']}'),
                        Text('Gender: ${subscriberData['gender']}'),
                        Text('Age: ${subscriberData['age']}'),
                        Text('User ID: ${subscriberData['userId']}'),
                      ],
                    ),
                  );
                } else {
                  // عرض رسالة تشير إلى أن المستخدم غير مخول لعرض المشتركين
                  return Center(
                    child: Text('You are not authorized to view this event\'s subscribers.'),
                  );
                }
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
