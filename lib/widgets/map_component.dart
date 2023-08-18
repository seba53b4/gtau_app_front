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
  Position? location;
  String? errorMsg;
  MapType _currentMapType = MapType.satellite;
  Set<Polyline> polylines = {};
  bool isSectionDetailsVisible = false;
  PolylineId selectedPolylineId = PolylineId('');
  Color selectedPolylineColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
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
        location = currentPosition;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location';
      });
    }
  }


  Future<List<Section>?> fetchPolylines(String token) async{
    final sectionViewModel = Provider.of<SectionViewModel>(context, listen: false);
    List<Section>? sections = await sectionViewModel.fetchSectionsByRadius(token, -34.88648, -56.13854, 500);
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

  void handlePolylinePress(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Línea clickeada'),
        content: Text('Línea con ID: $id fue clickeada'),
      ),
    );
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
              target: LatLng(-34.88773, -56.13955),
              zoom: 15,
            ),
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // GestureDetector(
          //   onTap: () {
          //   },
          //   child: AbsorbPointer(
          //     absorbing: isSectionDetailsVisible,
          //     child: MapSectionDetailsOverlay(
          //       isVisible: isSectionDetailsVisible,
          //       selectedPolylineId: selectedPolylineId,
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 14,
            left: 16,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMapType = MapType.normal;
                    });
                  },
                  child: Text("Normal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMapType = MapType.satellite;
                    });
                  },
                  child: Text("Satelital"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<Section>? newSections = await fetchPolylines(token!);
                    Set<Polyline> updatedPolylines = getPolylines(newSections);
                    setState(() {
                      polylines = updatedPolylines;
                    });
                  },
                  child: Text("Fetch Tramos"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
