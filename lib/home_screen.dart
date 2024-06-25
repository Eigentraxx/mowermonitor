import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mowerapp/contacts_screen.dart';
import 'package:mowerapp/database_screen.dart';
import 'package:mowerapp/mowercmds_screen.dart';
import 'package:mowerapp/powerstate_screen.dart';
import 'package:mowerapp/sms_screen.dart';
import 'locations_screen.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'package:animated_fab_button_menu/animated_fab_button_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FabMenu(
          fabBackgroundColor: Colors.blueGrey,
          elevation: 2.0,
          fabAlignment: Alignment.bottomCenter,
          fabIcon: const Icon(Icons.more_horiz),
          closeMenuButton: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          overlayOpacity: 0.5,
          overlayColor: Colors.blueAccent,
          children: [
            MenuItem(
              title: 'Contacts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FlutterContactsExample()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'Locations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserMapInfo()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'Messages',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmsApp()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'DataList',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataPage()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'Solar Power Data',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PowerPage()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'Cards',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomCards()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            MenuItem(
              title: 'Mower Commands',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommandPage()),
                );
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ]),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Image.asset('assets/imgs/ewatchcrop.png'),
      ),
    );
  }
}
