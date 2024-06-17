import 'package:flutter/material.dart';

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
  Set<Marker> markers = Set();
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
          : GoogleMap(
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              indoorViewEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16.0,
              ),
              markers: markers),
    );
  }
}
