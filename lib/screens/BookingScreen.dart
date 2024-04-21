import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled17/screens/paytriner.dart';

import '../payments.dart';

class Book extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InteractiveCalendarScreen(),
    );
  }
}

class InteractiveCalendarScreen extends StatefulWidget {
  @override
  _InteractiveCalendarScreenState createState() =>
      _InteractiveCalendarScreenState();
}

class _InteractiveCalendarScreenState extends State<InteractiveCalendarScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Map<String, dynamic>? bookingData; // تعريف المتغير bookingData هنا

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> saveBookingData(Map<String, dynamic> bookingData) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add(bookingData);
      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Calendar'),
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
                '${_selectedTime?.format(context)}' ?? 'Select Time',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _confirmTime();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Vodafone(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Confirm Time'),
              ),
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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _confirmTime() {
    if (_selectedDate != null && _selectedTime != null) {
      print('Confirmed Date: $_selectedDate');
      print('Confirmed Time: $_selectedTime');

      bookingData = {
        'date': _selectedDate,
        'time': _selectedTime,
        // يمكنك إضافة المزيد من المعلومات الخاصة بالحجز هنا
      };
    } else {
      print('Please select date and time');
    }
  }
}
