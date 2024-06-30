import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:json_table/json_table.dart';

class PowerPage extends StatefulWidget {
  @override
  _PowerPageState createState() => _PowerPageState();
}

String eligibleToVote(value) {
  var utc = DateTime.parse(value);

  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(utc.toLocal());
  return formattedDate;
}

class _PowerPageState extends State<PowerPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('data');
  List<Map<String, dynamic>> _items = [];
  var columns = [
    JsonTableColumn("lux", label: "Light"),
    JsonTableColumn("sparkxTwoAmps", label: "In Amps"),
    JsonTableColumn("sparkxamps", label: "Out Amps"),
    JsonTableColumn("visible", label: "Light"),
    JsonTableColumn("ts", label: "Time", valueBuilder: eligibleToVote)
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final DataSnapshot snapshot = await _databaseReference
        .limitToLast(800)
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
          : CustomCard(
              childPadding: 10,
              color: Colors.green,
              child: JsonTable(_items, columns: columns) //Text('pop'),
              ),
    );
  }
  /*
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
  */
}
