import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:quickalert/quickalert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

var responseText = 'placeholder';

class ResponseModel {
  int? userId;
  int? id;
  String? title;
  String? body;

  ResponseModel({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  ResponseModel.fromJson(dynamic json) {
    userId = json['operationalMode'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    map['id'] = id;
    map['title'] = title;
    map['body'] = body;
    return map;
  }
}

class CustomCards extends StatefulWidget {
  const CustomCards({super.key});

  @override
  State<CustomCards> createState() => CustomCardsState();
}

class CustomCardsState extends State<CustomCards> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Custom Cards Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('CustomCards'),
              Center(
                child: Wrap(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCard(
                      height: 50,
                      child: const FlutterLogo(
                        style: FlutterLogoStyle.horizontal,
                        size: 90,
                      ),
                    ),
                    CustomCard(
                      height: 50,
                      width: 100,
                      elevation: 6,
                      childPadding: 10,
                      color: Colors.green,
                      onTap: () {},
                      child: const Center(
                        child: Text(
                          'http',
                          style: TextStyle(
                            fontSize: 21,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    CustomCard(
                      height: 50,
                      width: 100,
                      borderRadius: 10,
                      color: Colors.red,
                      hoverColor: Colors.indigo,
                      splashColor: Colors.white,
                      onTap: () {
                        createRecord(context);
                      },
                      child: const Center(
                        child: Text(
                          'httpcall',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomCard(
                    height: 100,
                    width: 100,
                    elevation: 5,
                    child: AutoSizeText(
                      responseText,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 8,
                    ),
                  ),
                  CustomCard(
                    height: 100,
                    width: 100,
                    elevation: 5,
                    borderRadius: 150,
                    color: Colors.green,
                    hoverColor: Colors.yellow,
                    onTap: () {
                      fetchData();
                    },
                    child: const AutoSizeText(
                      'ppppppp',
                      style: TextStyle(fontSize: 10),
                      maxLines: 8,
                    ),
                  ),
                  CustomCard(
                    height: 100,
                    width: 100,
                    elevation: 5,
                    color: Colors.blue,
                    borderColor: Colors.white,
                    borderWidth: 2,
                    onTap: () {
                      getRecord(context);
                    },
                    child: const Center(
                      child: Text(
                        'get',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text('Custom3DCards'),
              CustomCard(
                elevation: 30,
                shadowColor: Colors.black,
                color: Colors.green,
                onTap: () async {
                  readData();
                },
                child: const SizedBox(
                    width: 500, height: 300, child: Text('whatever')),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> fetchData() async {
    Location location = Location();
    var locationData = await location.getLocation();
    log(locationData.latitude.toString());
    // Replace this URL with your API endpoint
    var urlWeather =
        'https://forecast.weather.gov/MapClick.php?lat=${locationData.latitude}&lon=${locationData.longitude}&FcstType=json';
    final response =
        //await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
        await http.get(Uri.parse(urlWeather));
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON

      final data = jsonDecode(response.body);
      print(data['currentobservation']);
      final cobs = data['currentobservation'];
      print(cobs['Temp']);
      return data; //data.map((json) => ResponseModel.fromJson(json)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load data');
    }
  }

  void createRecord(context) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/123");

    await ref.set({
      "name": "John",
      "age": 18,
      "address": {"line1": "100 Mountain View"}
    }).then((_) {
      // Data saved successfully!
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Transaction Completed Successfully!',
      );
    }).catchError((error) {
      // The write failed...
    });
  }

  void getRecord(context) async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    log(locationData.toString());

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref
        .child(
            '/mowerData/-NtgaLhJZiCB4TvegsJQ/data/attributes/battery/batteryPercent')
        .get();
    if (snapshot.exists) {
      print(snapshot.value);
      var info = json.decode(snapshot.value.toString());

      setState(() {
        responseText = json.encode(snapshot.value);
      });
    } else {
      print('No data available.');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Sorry, something went wrong',
      );
    }
  }
}

void readData() async {
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('mowerData').get();
  if (snapshot.exists) {
    print(snapshot.value);
    //snapshot.value
    Map<dynamic, dynamic>? x;
    x = snapshot.value as Map?;
    //   String x = jsonEncode(snapshot.value);
    // snapshot.value!.forEach();
    var value = Map<String, dynamic>.from(snapshot.value as Map);
    print('val');
    print(value);
    var title = value["soc"];
    print(value.length);
    // print(interpolation.traverse(x as Map?, 'battery'));
    for (var i = 0; i < value.length; i++) {
      //print(value[i]);
      //print(title);

      // print(x[i]);
      //  mainDataList.add(snapshot.value[i]['Item'].toString() +
      //     ' Qty: ' +
      //    snapshot.value?[i]['qty'].toString();;);
    }
  } else {
    print('No data available.');
  }
}
