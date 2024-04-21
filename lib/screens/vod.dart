import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VodafonePlayground extends StatelessWidget {
  final Map<String, dynamic>? bookingData;

  VodafonePlayground({Key? key, this.bookingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VodafonePlaygroundPage(bookingData: bookingData),
    );
  }
}

class VodafonePlaygroundPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const VodafonePlaygroundPage({Key? key, required this.bookingData}) : super(key: key);

  @override
  _VodafonePlaygroundPageState createState() => _VodafonePlaygroundPageState();
}

class _VodafonePlaygroundPageState extends State<VodafonePlaygroundPage> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime; // الوقت البدء
  TimeOfDay? _selectedEndTime; // الوقت الانتهاء
  File? _image;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay(hour: _selectedStartTime!.hour + 1, minute: _selectedStartTime!.minute); // افتراض أن مدة الحجز ساعة واحدة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vodafone Playground'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Text(
                  'Select Date:',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_selectedDate?.toLocal()}'.split(' ')[0] ?? 'Select Date',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 10),
                Text(
                  'Select Time:',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_selectedStartTime?.format(context)} - ${_selectedEndTime?.format(context)}' ?? 'Select Time',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _uploadImageAndSaveData,
              icon: Icon(Icons.upload),
              label: Text('Upload Image & Save Data'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );

    if (pickedStartTime != null && pickedStartTime != _selectedStartTime) {
      setState(() {
        _selectedStartTime = pickedStartTime;
        _selectedEndTime = TimeOfDay(hour: pickedStartTime.hour + 1, minute: pickedStartTime.minute); // تحديث الوقت الانتهاء عند تغيير الوقت البدء
      });
    }
  }

  Future<void> _uploadImageAndSaveData() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      if (_selectedDate != null && _selectedStartTime != null && _selectedEndTime != null) {
        final startTimeAsString = _selectedTimeToString(_selectedStartTime!);
        final endTimeAsString = _selectedTimeToString(_selectedEndTime!);
        final bookingData = {
          'date': _selectedDate,
          'start_time': startTimeAsString,
          'end_time': endTimeAsString,
          // You can add more booking information here
        };

        // Check if the selected time slot is already booked
        final isTimeSlotBooked = await _firestoreService.checkTimeSlotAvailability(bookingData);
        if (!isTimeSlotBooked) {
          // Time slot is available, proceed to save the booking data
          await _firestoreService.saveBookingDataWithImage(bookingData, _image!);
        } else {
          // Time slot is already booked, show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This time slot is already booked. Please select another time.'),
            ),
          );
        }
      } else {
        print('Please select date and time');
      }
    }
  }

  String _selectedTimeToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkTimeSlotAvailability(Map<String, dynamic> bookingData) async {
    try {
      final startTime = bookingData['start_time'];
      final endTime = bookingData['end_time'];
      final DateTime date = bookingData['date'];

      final QuerySnapshot querySnapshot = await _firestore
          .collection('bookings')
          .where('date', isEqualTo: date)
          .where('start_time', isLessThan: endTime)
          .where('end_time', isGreaterThan: startTime)
          .get();

      // If there are any documents returned, it means the time slot is already booked
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking time slot availability: $error');
      return true; // Assuming there's an error, so treat it as the time slot is already booked
    }
  }

  Future<void> saveBookingDataWithImage(Map<String, dynamic> bookingData, File image) async {
    try {
      // Upload the image to Firebase Storage
      // For simplicity, I'm assuming you have already set up Firebase Storage and have a reference to the location where you want to save the image
      // Replace 'images' with your actual storage path
      final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(image);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      // Add the image URL to the booking data
      bookingData['image_url'] = imageUrl;

      // Save the booking data to Firestore
      await _firestore.collection('bookings').add(bookingData);

      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }
}
