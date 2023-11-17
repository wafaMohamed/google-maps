import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/core/core_components/widgets/custom_text.dart';
import 'package:maps/core/utils/color_manager/color_manager.dart';

import '../core/utils/assets_manager/assets_manager.dart';

class HomeScreenGoogleMap extends StatefulWidget {
  const HomeScreenGoogleMap({Key? key}) : super(key: key);

  @override
  State<HomeScreenGoogleMap> createState() => _HomeScreenGoogleMapState();
}

class _HomeScreenGoogleMapState extends State<HomeScreenGoogleMap> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kCameraPosition = CameraPosition(
    target: LatLng(30.033333, 31.233334),
    zoom: 14,
  );

  final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId("1"),
        position: LatLng(30.033333, 31.233334),
        infoWindow: InfoWindow(
          title: "Google Map",
        )),
  ];

  String placeLocation = '';

  /// search address
  String search = '';

  void searchAndNavigateBar() async {
    List<Location> locations = await locationFromAddress(search);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          14.0,
        ),
      );

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("searched_location"),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: const InfoWindow(
              title: "Searched Location",
            ),
          ),
        );
      });
    }
  }

  /// Current Location
  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error: ${error.toString()}");
    });
    return await Geolocator.getCurrentPosition();
  }

  /// loading current location data and get address
  loadCurrentLocationData() {
    getCurrentLocation().then((value) async {
      print("My Current Location: ${"${value.latitude} ${value.longitude}"}");

      /// convert lat&long to address
      List<Placemark> placeMark =
          await placemarkFromCoordinates(value.latitude, value.longitude);
      placeLocation = '${placeMark.reversed.last.country}'
          '${placeMark.reversed.last.locality}'
          '${placeMark.reversed.last.street}';

      _markers.add(
        Marker(
          markerId: const MarkerId("id"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow:
              InfoWindow(title: "My Current Location", snippet: placeLocation
                  //" ${"${value.latitude} , ${value.longitude}"}"

                  ),
        ),
      );

      CameraPosition cameraPosition = CameraPosition(
          zoom: 14, target: LatLng(value.latitude, value.longitude));
      GoogleMapController currentLocationController = await _controller.future;
      currentLocationController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  /// styling map theme
  String mapTheme = '';

  @override
  void initState() {
    super.initState();
    loadCurrentLocationData();
    DefaultAssetBundle.of(context)
        .loadString(AssetsManager.standardMapStyleAsset)
        .then((value) {
      mapTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            text: "Google Map",
            color: ColorManager.grey,
          ),
        ),

        /// styling map
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString(AssetsManager.silverMapStyleAsset)
                              .then((style) {
                            value.setMapStyle(style);
                          });
                        });
                      },
                      child: CustomText2(
                        text: "Silver",
                        color: ColorManager.black,
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString(AssetsManager.nightMapStyleAsset)
                              .then((style) {
                            value.setMapStyle(style);
                          });
                        });
                      },
                      child: CustomText2(
                        text: "Night",
                        color: ColorManager.black,
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString(AssetsManager.darkMapStyleAsset)
                              .then((style) {
                            value.setMapStyle(style);
                          });
                        });
                      },
                      child: CustomText2(
                        text: "Dark",
                        color: ColorManager.black,
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString(AssetsManager.retroMapStyleAsset)
                              .then((style) {
                            value.setMapStyle(style);
                          });
                        });
                      },
                      child: CustomText2(
                        text: "Retro",
                        color: ColorManager.black,
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString(AssetsManager.standardMapStyleAsset)
                              .then((style) {
                            value.setMapStyle(style);
                          });
                        });
                      },
                      child: CustomText2(
                        text: "standard",
                        color: ColorManager.black,
                      ),
                    ),
                  ]),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kCameraPosition,
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers),
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController googleMapController) {
              googleMapController.setMapStyle(mapTheme);
              _controller.complete(googleMapController);
            },
          ),

          /// search bar
          Positioned(
            top: 10.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ColorManager.white,
              ),
              child: TextField(
                cursorColor: ColorManager.grey,
                decoration: InputDecoration(
                  hintText: "Enter Address",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 18.0, top: 12.0),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchAndNavigateBar();
                    },
                    icon: const Icon(
                      Icons.search_off,
                      size: 21,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 665, right: 300),
        child: Column(
          children: [
            /// current location
            FloatingActionButton(
                backgroundColor: ColorManager.green,
                heroTag: "2",
                child: const Icon(Icons.person),
                onPressed: () async {
                  await loadCurrentLocationData();
                }),
            const SizedBox(height: 10),

            /// animated Camera
            FloatingActionButton(
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
          ],
        ),
      ),
    );
  }
}
