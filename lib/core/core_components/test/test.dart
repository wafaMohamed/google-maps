import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/core/core_components/widgets/custom_text.dart';
import 'package:maps/core/utils/color_manager/color_manager.dart';

import '../../utils/assets_manager/assets_manager.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// to manage asynchronous operations & provide the result or error to any completion.
  final Completer<GoogleMapController> _controller = Completer();

  String placeM = '';
  String addressOnScreen = '';
  String allAddress = '';

  /// get address from lat and long by location geocoder
  transformLatLongToAddress() async {
    List<Location> location = await locationFromAddress("Cairo,Egypt");
    List<Placemark> placeMark =
    await placemarkFromCoordinates(30.033333, 31.232334);
    setState(() {
      /// show lat and long
      addressOnScreen =
      ' ${location.last.latitude}' ' ${location.last.longitude}';

      /// show country name
      placeM = '${placeMark.reversed.last.country}'
          '${placeMark.reversed.last.locality}';

      /// show lat and long
      allAddress = '${placeMark.reversed.last.country.toString()}'
          '${placeMark.reversed.last.locality.toString()}'
          '${placeMark.reversed.last.name.toString()}'
          '${placeMark.reversed.last.street.toString()}';
    });
  }

  /// multi markers
  final List<Marker> _marker = [];

  final List<Marker> _list = const [
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(30.033333, 31.233334),
        infoWindow: InfoWindow(
          title: "Hi",
          snippet: "my location so near of you!",
        )),
    Marker(
      markerId: MarkerId("2"),
      position: LatLng(30.033333, 31.232334),
      infoWindow: InfoWindow(
        title: "Hi",
        snippet: "welcome",
      ),
    ),
    Marker(
        markerId: MarkerId("3"),
        position: LatLng(30.033333, 31.238334),
        infoWindow: InfoWindow(
          title: "Hi",
          snippet: "welcome",
        )),
    Marker(
        markerId: MarkerId("4"),
        position: LatLng(30.033333, 31.263334),
        infoWindow: InfoWindow(
          title: "Hi",
          snippet: "welcome",
        )),
  ];
  /// markers
  var markers = HashSet<Marker>();
  /// get user current location
  Future<Position> getCurrentLocation() async {
     await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error: ${error.toString()}");
    });
    return await Geolocator.getCurrentPosition();
  }
  /// polyline
  List<Polyline> multiPolyline = [];

  createPolyline() {
    multiPolyline.add(
      Polyline(
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
            PatternItem.dot
          ],
          polylineId: const PolylineId("1"),
          color: ColorManager.green,
          width: 3,
          points: const [
            LatLng(30.033333, 31.233334),
            LatLng(30.032963, 31.228573),
          ]),
    );
  }

  /// custom marker
  late BitmapDescriptor customMarker;

  getCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, AssetsManager.marker2Asset);
  }

  @override
  void initState() {
    super.initState();
    getCustomMarker();
    createPolyline();
    _marker.addAll(_list);

  }

  /// polygons method
  Set<Polygon> polygonCoordinatesAndSet() {
    /// coordinates
    var polygonCoordinates = Set<LatLng>();
    polygonCoordinates
        .add(const LatLng(30.033333, 31.233334)); // Cairo coordinates
    polygonCoordinates.add(const LatLng(30.032963, 31.233573));
    polygonCoordinates.add(const LatLng(30.032963, 31.228573));
    polygonCoordinates.add(const LatLng(30.033333, 31.233334));

    /// polygons
    var polygonSet = Set<Polygon>();
    polygonSet.add(
      Polygon(
        polygonId: const PolygonId('1'),
        points: polygonCoordinates.toList(),
        strokeColor: ColorManager.green,
        strokeWidth: 50,
      ),
    );

    return polygonSet;
  }

  /// circle
  Set<Circle> mapCircle = {
    Circle(
      circleId: const CircleId('1'),
      strokeWidth: 2,
      radius: 1000,
      center: const LatLng(30.033333, 31.233334),
      fillColor: ColorManager.grey,
      strokeColor: ColorManager.black,
      visible: true,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            text: "Google Maps",
            color: ColorManager.black,
          ),
        ),
      ),
      body: GoogleMap(
        polylines: multiPolyline.toSet(),
        mapType: MapType.normal,
        circles: mapCircle,
        polygons: polygonCoordinatesAndSet(),
        markers: markers,
        onMapCreated: (GoogleMapController googleMapController) {
          setState(() {
            markers.add(
              Marker(
                icon: customMarker,
                markerId: const MarkerId("1"),
                position: const LatLng(30.033333, 31.233334),
                infoWindow:
                    const InfoWindow(title: "wafa", snippet: "Tracking now!"),
              ),
            );
          });
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.033333, 31.233334),
          zoom: 15,
        ),
      ),

      /// animated Camera
        floatingActionButton: FloatingActionButton(
          backgroundColor: ColorManager.green,
          heroTag: "1",
          child: const Icon(Icons.my_location),
          onPressed: () async {
            GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  target: LatLng(30.033333, 31.232334),
                  zoom: 14,
                ),
              ),
            );
          }),
    );
  }
}
