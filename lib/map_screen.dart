import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_utils/google_maps_utils.dart';

var responseText = 'placeholder';

class CustomCards extends StatefulWidget {
  const CustomCards({super.key});

  @override
  State<CustomCards> createState() => CustomCardsState();
}

class CustomCardsState extends State<CustomCards> {
  late GoogleMapController mapController;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('mowerData');
  LatLng? _currentPosition;
  // ignore: prefer_typing_uninitialized_variables
  var _latLngs;
  String timeStamp = '';
  bool _isLoading = true;
  final Set<Marker> markers = {};
  Set<Polygon> _polygons = {};
  List<LatLng> _gridPoints = [];
  List perimeterList = [];
  String gridMetrics = 'pending...';
  BitmapDescriptor secondIcon = BitmapDescriptor.defaultMarker;
  @override
  void initState() {
    super.initState();
    addCustomIcon();
    getLocation();
    gridMetrics = 'pending';
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/imgs/icon40.png")
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
        centerTitle: true,
        title: const Text('Mower Perimeter Set-up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('Site Work'),
              Center(
                child: Wrap(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCard(
                      height: 50,
                      width: 100,
                      borderRadius: 10,
                      color: Colors.red,
                      hoverColor: Colors.indigo,
                      splashColor: Colors.white,
                      onTap: () {
                        fetchData();
                      },
                      child: const Center(
                        child: Text(
                          'Save Area',
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
              const SizedBox(height: 25),
              const Text('Work Map'),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CustomCard(
                      elevation: 30,
                      height: 500,
                      width: 400,
                      shadowColor: Colors.black,
                      color: Colors.green,
                      onTap: () async {},
                      child: GoogleMap(
                          mapType: MapType.hybrid,
                          myLocationEnabled: true,
                          zoomControlsEnabled: true,
                          indoorViewEnabled: true,
                          onTap: (position) {
                            _addMarker(position);
                          },
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition!,
                            zoom: 20,
                          ),
                          markers: markers,
                          polygons: _polygons),
                    ),
              CustomCard(
                borderRadius: 10,
                color: Colors.green,
                hoverColor: Colors.indigo,
                splashColor: Colors.white,
                onTap: () {
                  saveLocations();
                },
                child: const Center(
                  child: Text(
                    'Create Areas',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              CustomCard(
                color: Colors.white,
                hoverColor: Colors.indigo,
                splashColor: Colors.white,
                onTap: () {},
                child: const Center(
                  child: Text(
                    'pending',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveLocations() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = pos.latitude;
    double lng = pos.longitude;

    LatLng loc = LatLng(lat, lng);
    perimeterList.add({'lat': lat, 'lng': lng});

    for (var marker in markers) {
      LatLng position = marker.position;
      print(
          'Marker ID: ${marker.markerId}, Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    }
    _createPolygon();
  }

  void _createPolygon() {
    List<LatLng> polygonCoords =
        markers.map((marker) => marker.position).toList();

    setState(() {
      _polygons.add(
        Polygon(
          polygonId: PolygonId('polygon_1'),
          points: polygonCoords,
          strokeColor: Colors.blue,
          strokeWidth: 3,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      );
    });

    double perimeter = _calculatePerimeter(polygonCoords);
    double area = _calculateArea(polygonCoords);

    print('Perimeter: $perimeter meters');
    print('Area: $area square meters');
    String x =
        'Perimeter length: ${perimeter.toStringAsFixed(2)} Area: ${area.toStringAsFixed(2)}';
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: x,
    );
    _generateGridPoints(polygonCoords);
  }

  Future<String> fetchData() async {
    // Location location = Location();
    // var locationData = await location.getLocation();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double lng = position.longitude;

    return lat.toString();

    /* for adifferent application
    var urlWeather =
        'https://forecast.weather.gov/MapClick.php?lat=${lat}&lon=${lng}&FcstType=json';
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
    */
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());
    final marker = Marker(
        markerId: markerId,
        position: position,
        //  infoWindow: InfoWindow(
        //  title: 'Marker for line',
        //),
        icon: secondIcon);

    setState(() {
      markers.add(marker);
    });
  }

  double _calculateArea(List<LatLng> points) {
    const double radius = 6371000; // Earth's radius in meters
    double area = 0.0;

    for (int i = 0; i < points.length; i++) {
      LatLng p1 = points[i];
      LatLng p2 = points[(i + 1) % points.length];
      area += (p2.longitude - p1.longitude) *
          (2 + sin(p1.latitude * pi / 180) + sin(p2.latitude * pi / 180));
    }

    area = area * radius * radius / 2.0;
    return area.abs();
  }

  double _calculatePerimeter(List<LatLng> points) {
    double totalDistance = 0.0;

    for (int i = 0; i < points.length; i++) {
      LatLng start = points[i];
      LatLng end = points[(i + 1) % points.length];
      totalDistance += _haversineDistance(start, end);
    }

    return totalDistance;
  }

  double _haversineDistance(LatLng start, LatLng end) {
    const double radius = 6371000; // Earth's radius in meters

    double dLat = (end.latitude - start.latitude) * pi / 180;
    double dLng = (end.longitude - start.longitude) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * pi / 180) *
            cos(end.latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  void _generateGridPoints(List<LatLng> polygonCoords) {
    // Calculate the bounding box of the polygon
    double minLat = polygonCoords.map((p) => p.latitude).reduce(min);
    double maxLat = polygonCoords.map((p) => p.latitude).reduce(max);
    double minLng = polygonCoords.map((p) => p.longitude).reduce(min);
    double maxLng = polygonCoords.map((p) => p.longitude).reduce(max);

    const double meterInDegrees = 1 / 111320; // Approximation
    List<LatLng> gridPoints = [];
    for (double lat = minLat; lat <= maxLat; lat += meterInDegrees) {
      for (double lng = minLng; lng <= maxLng; lng += meterInDegrees) {
        LatLng point = LatLng(lat, lng);
        if (_isPointInPolygon(point, polygonCoords)) {
          gridPoints.add(point);
        }
      }
    }

    // check points created as they sometimes lie out side the polygon
    List<Point> polygonPoints = polygonCoords
        .map((latLng) => Point(latLng.latitude, latLng.longitude))
        .toList();

    _gridPoints = gridPoints.where((point) {
      Point p = Point(point.latitude, point.longitude);
      return PolyUtils.containsLocationPoly(p, polygonPoints);
    }).toList();
    for (var i = 0; i < _gridPoints.length; i++) {
      _addMarker(_gridPoints[i]);
    }
    print('Total grid points inside the polygon: ${_gridPoints.length}');
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // odd = inside, even = outside;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    double m = (aY - bY) / (aX - bX);
    double bee = -aX * m + aY;
    double x = (pY - bee) / m;

    return x > pX;
  }
}
