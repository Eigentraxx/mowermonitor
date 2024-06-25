import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'database_screen.dart';

class UserMapInfo extends StatefulWidget {
  const UserMapInfo({Key? key}) : super(key: key);

  @override
  State<UserMapInfo> createState() => _UserMapInfoState();
}

class _UserMapInfoState extends State<UserMapInfo> {
  late GoogleMapController mapController;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('mowerData');
  LatLng? _currentPosition;
  // ignore: prefer_typing_uninitialized_variables
  var _latLngs;
  String timeStamp = '';
  bool _isLoading = true;
  final Set<Marker> markers = {};
  // BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor secondIcon = BitmapDescriptor.defaultMarker;
  @override
  void initState() {
    super.initState();
    _database.onValue.listen((event) {
      var items;

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        var strDate = convertTimestampToDate(
            value['data']['attributes']['metadata']['statusTimestamp']);

        items = (value['data']['attributes']['positions']);

        timeStamp = (strDate);
      });

      setState(() {
        _latLngs = items;
      });
    });

    addCustomIcon();
    getLocation();
  }

  void addCustomIcon() {
    /*
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/imgs/ewatchcrop.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
    */
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/imgs/icon16.png")
        .then(
      (icon) {
        setState(() {
          secondIcon = icon;
        });
      },
    );
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    Marker resultMarker = Marker(
        markerId: const MarkerId("marker1"),
        position: location,
        draggable: true,
        onDragEnd: (value) {
          // value is the new position
        },
        icon: secondIcon
        // To do: custom marker icon
        );
// Add it to Set
    markers.add(resultMarker);
    print(_latLngs);
    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('CustomCards'),
                      Center(
                        child: CustomCard(
                          elevation: 30,
                          shadowColor: Colors.black,
                          color: Colors.green,
                          child: SizedBox(
                            width: 500,
                            height: 500,
                            child: GoogleMap(
                                myLocationEnabled: true,
                                zoomControlsEnabled: true,
                                indoorViewEnabled: true,
                                onTap: (position) {
                                  //_addMarker(position);
                                },
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: _currentPosition!,
                                  zoom: 16.0,
                                ),
                                markers: markers),
                          ),
                        ),
                      ),
                      CustomCard(
                        height: 50,
                        elevation: 6,
                        childPadding: 10,
                        color: Colors.blueAccent,
                        onTap: () {
                          getLocationsMower();
                        },
                        child: const Center(
                          child: Text(
                            'Get Locations Mower',
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  void getLocationsMower() {
    print(timeStamp);
    print(_latLngs.length);
    for (var i = 0; i < _latLngs.length; i++) {
      LatLng location =
          LatLng(_latLngs[i]['latitude'], _latLngs[i]['longitude']);

      //LatLng location = LatLng(lat, lng);
      Marker marker = Marker(
        markerId: MarkerId("marker" + i.toString()),
        position: location,
        draggable: true,
        onDragEnd: (value) {
          // value is the new position
        },
        icon: secondIcon,
        infoWindow: InfoWindow(
          title: 'Marker # ' + timeStamp,
        ),
      );
      markers.add(marker);
    }
    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_latLngs[1]['latitude'], _latLngs[1]['longitude']), 18));
    });
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: 'Marker at ${position.latitude}, ${position.longitude}',
      ),
    );

    setState(() {
      markers.add(marker);
    });
  }
}
