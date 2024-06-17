import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'dart:convert';
import 'dart:developer';
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
                    borderRadius: 50,
                    color: Colors.green,
                    hoverColor: Colors.yellow,
                    onTap: () {
                      log('called');
                    },
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
                onTap: () async {},
                child:
                    SizedBox(width: 500, height: 300, child: Text('whatever')),
              ),
              const SizedBox(height: 30),
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
    final snapshot = await ref.child('users/123').get();
    if (snapshot.exists) {
      print(snapshot.value);
      var info = json.decode(snapshot.value.toString());
      print(info['name']);
      setState(() {
        responseText = info['age'];
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
