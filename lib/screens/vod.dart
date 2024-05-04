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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay(hour: 10, minute: 0); // تعيين الوقت الابتدائي للتوقيت المتاح من الساعة 10 صباحًا
    _selectedEndTime = TimeOfDay(hour: 1, minute: 0); // تعيين الوقت النهائي للتوقيت المتاح حتى الساعة 1 بعد منتصف الليل
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vodafone Playground'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 10),
                  Text(
                    'Name:',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 10),
                  Text(
                    'Phone Number:',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
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
        final name = _nameController.text;
        final phoneNumber = _phoneController.text;

        // Check if the selected time is within working hours
        final selectedStartTimeHour = _selectedStartTime!.hour;
        final selectedEndTimeHour = _selectedEndTime!.hour;
        if (selectedStartTimeHour < 10 || selectedEndTimeHour > 1) {
          // If the selected time is before 10 AM or after 1 PM, display a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Working hours are from 10 AM to 1 AM.'),
            ),
          );
          return;
        }

        final bookingData = {
          'date': _selectedDate,
          'start_time': startTimeAsString,
          'end_time': endTimeAsString,
          'name': name,
          'phone_number': phoneNumber,
        };

        final isTimeSlotBooked = await _firestoreService.checkTimeSlotAvailability(bookingData);
        if (!isTimeSlotBooked) {
          await _firestoreService.saveBookingDataWithImage(bookingData, _image!);
        } else {
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

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking time slot availability: $error');
      return true;
    }
  }

  Future<void> saveBookingDataWithImage(Map<String, dynamic> bookingData, File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(image);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      bookingData['image_url'] = imageUrl;

      await _firestore.collection('bookings').add(bookingData);

      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }
}

void main() {
  runApp(VodafonePlayground());
}