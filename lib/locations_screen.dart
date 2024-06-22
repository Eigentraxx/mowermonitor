import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

class UserMapInfo extends StatefulWidget {
  const UserMapInfo({Key? key}) : super(key: key);

  @override
  State<UserMapInfo> createState() => _UserMapInfoState();
}

class _UserMapInfoState extends State<UserMapInfo> {
  late GoogleMapController mapController;

  LatLng? _currentPosition;

  bool _isLoading = true;
  final Set<Marker> markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  @override
  void initState() {
    super.initState();
    addCustomIcon();
    getLocation();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/imgs/ewatchcrop.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
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
        icon: markerIcon
        // To do: custom marker icon
        );
// Add it to Set
    markers.add(resultMarker);

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
                                  _addMarker(position);
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
    double lat = 41.86944;
    double long = -88.28724;

    LatLng location = LatLng(lat, long);
    Marker marker = Marker(
      markerId: const MarkerId("marker2"),
      position: location,
      draggable: true,
      onDragEnd: (value) {
        // value is the new position
      },
      infoWindow: InfoWindow(
        title: 'Marker at $lat, $long',
      ),
    );
    setState(() {
      markers.add(marker);
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
