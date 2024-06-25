import 'dart:convert';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database_screen.dart';

class CommandPage extends StatefulWidget {
  @override
  _CommandPageState createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  final DatabaseReference _databaseReferenceCMD =
      FirebaseDatabase.instance.ref('mowerCommandResponse');
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('mowerCommands');
  final DatabaseReference _databaseReferenceMowerData =
      FirebaseDatabase.instance.ref('mowerData');
  final DatabaseReference _databaseReferenceAllData =
      FirebaseDatabase.instance.ref('data');
  final TextEditingController _controller = TextEditingController();
  String _newValue = '';
  String _newEntry = '';
  String _cmdValue = '';
  List<String> list = <String>[
    'Start',
    'ParkUntilFurtherNotice',
    'Headlights On',
    'ParkUntilNextSchedule'
  ];
  @override
  void initState() {
    super.initState();
    _databaseReferenceCMD.onChildAdded.listen(_onEntryAdded);
    _databaseReferenceMowerData.onChildAdded.listen(_onEntryNew);
  }

  void _onEntryAdded(DatabaseEvent event) {
    setState(() {
      _newValue = event.snapshot.value.toString();
    });
  }

  void _onEntryNew(DatabaseEvent event) {
    var strDate = '';
    var noticeStr = '';
    setState(() {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        noticeStr = value['attributes']['mower'].toString();
        strDate = convertTimestampToDate(
            value['attributes']['metadata']['statusTimestamp']);
      });

      _newEntry = noticeStr;
    });
  }

  void _addData() {
    String value = _controller.text;
    String go = '{"data":{"attributes":{"duration":20},"type":"Start"}}';
    var cmd = jsonDecode(go);
    _databaseReference.push().set(cmd);
    _controller.clear();
  }

  void _getData() {
    String value = _controller.text;
    String go = '{"data":{"attributes":{"duration":20},"type":"Start"}}';
    var cmd = jsonDecode(go);
    _databaseReferenceAllData.push().set(cmd);
    _controller.clear();
  }

  void _parseRecord(record) {
    final data = record.toString();
    var d = jsonEncode(record).toString();
    Map x = jsonEncode(d) as Map;
    var y = x['mode'];
    print(y.toString());
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = list.first;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mower Command And Response'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter Value',
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                    _cmdValue = value;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _addData,
                child: Text('Send Command'),
              ),
              SizedBox(height: 20),
              if (_newValue.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'New Value Added: $_newValue',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _getData,
                child: Text('Get Status'),
              ),
              SizedBox(height: 20),
              if (_newEntry.isNotEmpty)
                CustomCard(
                  onTap: () {
                    _parseRecord(_newEntry);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'New Value Added: $_newEntry',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              if (_cmdValue.isNotEmpty)
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Command To Send:: $_cmdValue',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
