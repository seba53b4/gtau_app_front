import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/section_data.dart';
import '../providers/user_provider.dart';

class MapComponent extends StatefulWidget {
  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  LatLng? location;
  static const LatLng initLocation = LatLng(-34.88773, -56.13955);
  String? errorMsg;
  List<String> distances = ["100", "200", "300", "500"];
  int distanceSelected = 0;
  MapType _currentMapType = MapType.satellite;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  bool isSectionDetailsVisible = false;
  PolylineId selectedPolylineId = PolylineId('');
  Color selectedPolylineColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;
  Color selectedButtonColor = Colors.green;
  Color defaultButtonColor = Colors.primaries.first;
  bool locationManual = false;
  late Completer<GoogleMapController> _mapController;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _mapController = Completer();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          errorMsg = 'Permission to access location was denied';
        });
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        final locationGPS = LatLng(currentPosition.latitude, currentPosition.longitude);
        final Marker newMarker = Marker(
          markerId: const MarkerId('tapped_location'),
          position: locationGPS,
        );
        location = locationGPS;
        markers.add(newMarker);
      });

      // Actualiza la cámara del mapa para centrarse en la ubicación actual
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPosition.latitude, currentPosition.longitude),
            zoom: 15,
          ),
        ),
      );

    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location';
      });
    }
  }


  Future<List<Section>?> fetchPolylines(String token) async{
    final sectionViewModel = Provider.of<SectionViewModel>(context, listen: false);
    List<Section>? sections;
    if (location != null){
      sections = await sectionViewModel.fetchSectionsByRadius(token, location!.latitude, location!.longitude, int.parse(distances[distanceSelected]));
    } else {
      sections = await sectionViewModel.fetchSectionsByRadius(token, initLocation.latitude, initLocation.longitude,  int.parse(distances[distanceSelected]));
    }

    return sections;
  }


  Set<Polyline> getPolylines(List<Section>? sections) {
    if (sections != null) {
      Set<Polyline> setPol = {};
      for (var section in sections) {
        Polyline pol = section.line.copyWith(
          colorParam: selectedPolylineId == section.line.polylineId
              ? selectedPolylineColor
              : defaultPolylineColor,
          onTapParam: () {
            Set<Polyline> updatedPolylines = getPolylines(sections);
            setState(() {
              isSectionDetailsVisible = !isSectionDetailsVisible;
              selectedPolylineId = section.line.polylineId;
              polylines = updatedPolylines;
            });
          },
        );
        setPol.add(pol);
      }
      return setPol;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().getToken;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: const CameraPosition(
              target: initLocation,
              zoom: 15,
            ),
            polylines: polylines,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            onTap: (LatLng latLng) {
              if (locationManual) {
                setState(() {
                  final Marker newMarker = Marker(
                    markerId: const MarkerId('tapped_location_manual'),
                    position: latLng,
                  );
                  markers.clear();
                  markers.add(newMarker);
                  location = LatLng(latLng.latitude, latLng.longitude);
                });
              }
            },
          ),
          Positioned(
            bottom: 14,
            left: 16,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
                    });
                  },
                  child: _currentMapType == MapType.normal ? Text("Normal") : Text("Satelite"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<Section>? newSections = await fetchPolylines(token!);
                    Set<Polyline> updatedPolylines = getPolylines(newSections);
                    setState(() {
                      polylines = updatedPolylines;
                    });
                  },
                  child: const Text("Fetch Tramos"),
                ),
                ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: const Text("Obtener Ubicación"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (locationManual) ? selectedButtonColor : defaultButtonColor ,
                  ),
                  onPressed: () {
                    setState(() {
                      locationManual = !locationManual;
                    });
                  },
                  child: const Text("Seleccionar Ubicación"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      distanceSelected = (distanceSelected + 1) % distances.length;
                    });
                  },
                  child: Text(distances[distanceSelected].toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
