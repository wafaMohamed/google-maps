import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/assets_manager/assets_manager.dart';

class CustomMultipleMarker extends StatefulWidget {
  const CustomMultipleMarker({Key? key}) : super(key: key);

  @override
  State<CustomMultipleMarker> createState() => _CustomMultipleMarkerState();
}

class _CustomMultipleMarkerState extends State<CustomMultipleMarker> {
  final Completer<GoogleMapController> _controller = Completer();

  List<String> images = [
    AssetsManager.carAsset,
    AssetsManager.car2Asset,
    AssetsManager.marker2Asset,
    AssetsManager.marker3Asset,
    AssetsManager.markerAsset,
    AssetsManager.motorCycleAsset,
  ];

  List<LatLng> latLng = const <LatLng>[
    LatLng(30.033333, 31.233334), // Cairo, Egypt
    LatLng(30.033333, 31.216667),
    LatLng(30.033333, 31.218333),
    LatLng(30.033333, 31.223333),
    LatLng(30.033333, 31.226167),
    LatLng(30.033333, 31.233667),
    LatLng(30.033333, 31.219167),
  ];

  static const CameraPosition _kCameraPosition = CameraPosition(
    target: LatLng(30.033333, 31.233334),
    zoom: 14,
  );

  final List<Marker> markers = <Marker>[];

  Uint8List? markerImage;

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  loadData() async {
    for (int i = 0; i < images.length; i++) {
      final Uint8List markerIcon =
          await getBytesFromAssets(images[i].toString(), 100);
      markers.add(
        Marker(
            markerId: MarkerId(i.toString()),
            position: latLng[i],
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: const InfoWindow(title: 'The title of the marker')),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kCameraPosition,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: Set<Marker>.of(markers),
        onMapCreated: (GoogleMapController googleMapController) {
          _controller.complete(googleMapController);
        },
      ),
    );
  }
}
