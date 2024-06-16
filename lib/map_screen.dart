import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:quickalert/quickalert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:location/location.dart';

var responseText = 'placeholder';

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

  // https://developers.google.com/books/docs/overview
  var url =
      Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Custom Cards Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('CustomCards'),
              Center(
                child: Wrap(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCard(
                      height: 50,
                      child: FlutterLogo(
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
                      child: Center(
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
                      child: Center(
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
              SizedBox(height: 8),
              Wrap(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomCard(
                    height: 100,
                    width: 100,
                    elevation: 5,
                    child: AutoSizeText(
                      responseText,
                      style: TextStyle(fontSize: 10),
                      maxLines: 8,
                    ),
                  ),
                  CustomCard(
                    height: 100,
                    width: 100,
                    elevation: 5,
                    borderRadius: 50,
                    color: Colors.green,
                    hoverColor: Colors.yellow,
                    onTap: () {
                      log('called');
                    },
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
                    child: Center(
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
              SizedBox(height: 25),
              Text('Custom3DCards'),
              Wrap(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Custom3DCard(
                      elevation: 4,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: FlutterLogo(size: 65),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Custom3DCard(
                      elevation: 10,
                      shadowSpread: 5,
                      shadowColor: Colors.brown.shade400,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: FlutterLogo(
                            size: 65,
                            style: FlutterLogoStyle.stacked,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
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
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    log(_locationData.toString());

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/123').get();
    if (snapshot.exists) {
      print(snapshot.value);
      var info = json.encode(snapshot.value);
      setState(() {
        responseText = info;
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
