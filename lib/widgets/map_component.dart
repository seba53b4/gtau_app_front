import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/section_data.dart';
import '../providers/user_provider.dart';

class MapComponent extends StatefulWidget {
  final bool isModal;
  const MapComponent({super.key, this.isModal = false});

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
  Color selectedPolylineColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;
  Color selectedButtonColor = Colors.green;
  Color defaultButtonColor = Colors.primaries.first;
  bool locationManual = false;
  static const double zoom = 15;
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
            zoom: zoom,
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

  void _onTapParamBehavior(Section section, List<Section>? sections ) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    selectedItemsProvider.toggleSectionSelected(section.line.polylineId);
  }

  Color _onColorParamBehavior(Section section){
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isSectionSelected(section.line.polylineId)
            ? selectedPolylineColor
            : defaultPolylineColor;
  }



  Set<Polyline> getPolylines(List<Section>? sections) {

    if (sections != null) {
      Set<Polyline> setPol = {};
      for (var section in sections) {
        Polyline pol = section.line.copyWith(
          colorParam: _onColorParamBehavior(section),
          onTapParam: () {
            _onTapParamBehavior(section, sections);
            setState(() {
              polylines = getPolylines(sections);
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
              zoom: zoom,
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
                  child: _currentMapType == MapType.normal ? Text(AppLocalizations.of(context)!.map_component_normal_view) : Text(AppLocalizations.of(context)!.map_component_sattelite_view),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<Section>? newSections = await fetchPolylines(token!);
                    Set<Polyline> updatedPolylines = getPolylines(newSections);
                    setState(() {
                      polylines = updatedPolylines;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.map_component_fetch_sections),
                ),
                ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: Text(AppLocalizations.of(context)!.map_component_get_location),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (locationManual) ? selectedButtonColor : defaultButtonColor ,
                  ),
                  onPressed: () {
                    setState(() {
                      polylines = {};
                      locationManual = !locationManual;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.map_component_select_location),
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
