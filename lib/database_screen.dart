
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('mowerData');
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _database.onValue.listen((event) {
      final List<String> items = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        var strDate = convertTimestampToDate(
            value['data']['attributes']['metadata']['statusTimestamp']);

        items.add('Battery Perc: ${value['data']['attributes']['battery']['batteryPercent']}  @ $strDate');
      });
      setState(() {
        _items = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase RTDB ListView'),
      ),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                );
              },
            ),
    );
  }
}

// functions
String convertTimestampToDate(int timestamp) {
  // Create a DateTime object from the timestamp (milliseconds since epoch)
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // Format the DateTime object as a string
  String formattedDate =
      "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)}";

  return formattedDate;
}

// Helper function to ensure two digits for month, day, hour, minute, second
String _twoDigits(int n) {
  return n.toString().padLeft(2, '0');
}
