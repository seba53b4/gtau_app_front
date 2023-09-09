import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/catchment_data.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/section_data.dart';
import '../providers/user_provider.dart';
import '../utils/map_functions.dart';

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
  Set<Circle> circles = {};
  Set<Marker> markersGPS = {};
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
        final locationGPS =
            LatLng(currentPosition.latitude, currentPosition.longitude);
        final Marker newMarker = Marker(
          markerId: const MarkerId('tapped_location'),
          position: locationGPS,
        );
        location = locationGPS;
        markersGPS.add(newMarker);
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

  Future<List<Section>?> fetchPolylines(String token) async {
    final sectionViewModel =
        Provider.of<SectionViewModel>(context, listen: false);
    List<Section>? sections;
    if (location != null) {
      sections = await sectionViewModel.fetchSectionsByRadius(
          token,
          location!.latitude,
          location!.longitude,
          int.parse(distances[distanceSelected]));
    } else {
      sections = await sectionViewModel.fetchSectionsByRadius(
          token,
          initLocation.latitude,
          initLocation.longitude,
          int.parse(distances[distanceSelected]));
    }

    return sections;
  }

  Future<List<Catchment>?> fetchCircles(String token) async {
    final catchmentViewModel =
        Provider.of<CatchmentViewModel>(context, listen: false);
    List<Catchment>? catchments;
    if (location != null) {
      catchments = await catchmentViewModel.fetchSectionsByRadius(
          token,
          location!.latitude,
          location!.longitude,
          int.parse(distances[distanceSelected]));
    } else {
      catchments = await catchmentViewModel.fetchSectionsByRadius(
          token,
          initLocation.latitude,
          initLocation.longitude,
          int.parse(distances[distanceSelected]));
    }

    return catchments;
  }

  void _onTapParamBehaviorSection(Section section, List<Section>? sections) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    selectedItemsProvider.toggleSectionSelected(section.line.polylineId);
  }

  void _onTapParamBehaviorCatchment(
      Catchment catchment, List<Catchment>? catchments) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    selectedItemsProvider.toggleCaptacionSelected(catchment.point.circleId);
  }

  Color _onColorParamBehaviorSection(Section section) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isSectionSelected(section.line.polylineId)
        ? selectedPolylineColor
        : defaultPolylineColor;
  }

  Color _onColorParamBehaviorCatchment(Catchment catchment) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isCaptacionSelected(catchment.point.circleId)
        ? selectedPolylineColor
        : catchment.point.strokeColor;
  }

  void _getMarkers() {
    setState(() {
      markers.clear();
      markers.addAll(markersGPS);
    });
  }

  void _clearMarkers() {
    setState(() {
      markers.clear();
      markersGPS.clear();
    });
  }

  Set<Polyline> getPolylines(List<Section>? sections) {
    if (sections != null) {
      Set<Polyline> setPol = {};
      for (var section in sections) {
        Polyline pol = section.line.copyWith(
          colorParam: _onColorParamBehaviorSection(section),
          onTapParam: () {
            _onTapParamBehaviorSection(section, sections);
            setState(() {
              polylines = getPolylines(sections);
            });
          },
        );
        setPol.add(pol);
        setPol.addAll(
            polylineArrows(section.line.points, section.line.polylineId));
      }
      return setPol;
    } else {
      return {};
    }
  }

  Set<Circle> getCircles(List<Catchment>? catchments) {
    if (catchments != null) {
      Set<Circle> setCir = {};
      for (var catchment in catchments) {
        Circle pol = catchment.point.copyWith(
          centerParam: catchment.point.center,
          radiusParam: catchment.point.radius,
          strokeWidthParam: catchment.point.strokeWidth,
          strokeColorParam: _onColorParamBehaviorCatchment(catchment),
          onTapParam: () {
            _onTapParamBehaviorCatchment(catchment, catchments);
            setState(() {
              circles = getCircles(catchments);
            });
          },
        );
        setCir.add(pol);
      }
      return setCir;
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
            circles: circles,
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
                  markersGPS.clear();
                  markersGPS.add(newMarker);
                  _getMarkers();
                  location = LatLng(latLng.latitude, latLng.longitude);
                });
              }
            },
          ),
          Positioned(
            bottom: 80,
            left: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMapType = _currentMapType == MapType.normal
                          ? MapType.satellite
                          : MapType.normal;
                    });
                  },
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .map_component_map_view_tooltip,
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 1000),
                    child: Icon(
                      _currentMapType == MapType.normal
                          ? Icons.map
                          : Icons.satellite,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (kIsWeb) Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                ElevatedButton(
                  onPressed: () async {
                    List<Section>? newSections = await fetchPolylines(token!);
                    Set<Polyline> updatedPolylines = getPolylines(newSections);

                    List<Catchment>? newCatchments = await fetchCircles(token!);
                    Set<Circle> updatedCircles = getCircles(newCatchments);

                    setState(() {
                      polylines = updatedPolylines;
                      circles = updatedCircles;
                    });
                  },
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .map_component_fetch_elements,
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 1000),
                    child: const Icon(
                      Icons.area_chart_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (kIsWeb) Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                    _getMarkers();
                  },
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .map_component_get_location,
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 1000),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (kIsWeb) Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (locationManual)
                        ? selectedButtonColor
                        : defaultButtonColor,
                  ),
                  onPressed: () {
                    setState(() {
                      polylines = {};
                      circles = {};
                      locationManual = !locationManual;
                    });
                  },
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .map_component_select_location,
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 1000),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (kIsWeb) Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      distanceSelected =
                          (distanceSelected + 1) % distances.length;
                    });
                  },
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .map_component_diameter_tooltip,
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 1000),
                    child: Text(distances[distanceSelected].toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
