import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';

class PowerPage extends StatefulWidget {
  @override
  _PowerPageState createState() => _PowerPageState();
}

class _PowerPageState extends State<PowerPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('data');
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final DataSnapshot snapshot = await _databaseReference
        .limitToLast(100)
        .orderByChild('ts')
        .once()
        .then((value) => value.snapshot);
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      _items =
          data.entries.map((e) => Map<String, dynamic>.from(e.value)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solar Power Metrics'),
      ),
      body: _items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CustomCard(
                  childPadding: 10,
                  color: Colors.green,
                  child: ListTile(
                    title: Text(item['ts'] ?? 'No Date'),
                    subtitle: Text('Amps In:' +
                            item['sparkxamps'] +
                            '\n' +
                            'Amps Out ' +
                            item['sparkxTwoAmps'] +
                            '\n' +
                            'Light ' +
                            item['lux'] ??
                        'No Description'),
                  ),
                );
              },
            ),
    );
  }
}
