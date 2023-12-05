import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/lot_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/register_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';
import '../providers/user_provider.dart';
import 'common/menu_button_map.dart';

class MapComponentLocationSelect extends StatefulWidget {
  final bool isModal;

  const MapComponentLocationSelect({super.key, this.isModal = false});

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponentLocationSelect> {
  LatLng? location;
  static const LatLng initLocation = LatLng(-34.88773, -56.13955);
  String? errorMsg;
  final MapType _currentMapType = MapType.satellite;
  Set<Marker> markers = {};
  Set<Marker> markersGPS = {};
  bool locationManual = false;
  double zoomMap = 16;
  late Completer<GoogleMapController> _mapController;
  double modalWidth = 300.0;
  late double mapWidth;
  late double mapInit;
  late SelectedItemsProvider selectedItemsProvider;

  @override
  void initState() {
    super.initState();

    _mapController = Completer<GoogleMapController>();
    selectedItemsProvider = context.read<SelectedItemsProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapInit = MediaQuery
        .of(context)
        .size
        .width;
    setState(() {
      mapWidth = mapInit;
    });
    _initializeLocation();
  }

  @override
  void dispose() {
    super.dispose();
    selectedItemsProvider.reset();
  }

  Future<void> _initializeLocation() async {
    try {
      if (selectedItemsProvider.inspectionPosition.latitude == 0 &&
          selectedItemsProvider.inspectionPosition.longitude == 0) {
        getCurrentLocation();
      } else {
        setState(() {
          final locationGPS = selectedItemsProvider.inspectionPosition;
          final Marker newMarker = Marker(
            markerId: const MarkerId('current_position'),
            position: locationGPS,
          );
          location = locationGPS;
          markersGPS.add(newMarker);
          _getMarkers();
        });

        // Actualiza la cámara del mapa para centrarse en la ubicación actual sin animación
        final GoogleMapController controller = await _mapController.future;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(selectedItemsProvider.inspectionPosition.latitude,
                  selectedItemsProvider.inspectionPosition.longitude),
              zoom: zoomMap,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location';
      });
    }
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

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        final locationGPS =
        LatLng(currentPosition.latitude, currentPosition.longitude);
        final Marker newMarker = Marker(
          markerId: const MarkerId('current_gps_location'),
          position: locationGPS,
        );
        location = locationGPS;
        markersGPS.add(newMarker);
        _getMarkers();
      });
      selectedItemsProvider.setInspectionPosition(
          LatLng(currentPosition.latitude, currentPosition.longitude));
      // Actualiza la cámara del mapa para centrarse en la ubicación actual sin animación
      final GoogleMapController controller = await _mapController.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPosition.latitude, currentPosition.longitude),
            zoom: zoomMap,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location';
      });
    }
  }

  void _getMarkers() {
    setState(() {
      markers.clear();
      markers.addAll(markersGPS);
    });
  }

  void _clearMarkersGPS() {
    setState(() {
      markersGPS.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = context
        .read<UserProvider>()
        .getToken;

    return Consumer<SectionViewModel>(
        builder: (context, sectionViewModel, child) {
          return Consumer<RegisterViewModel>(
              builder: (context, registerViewModel, child) {
                return Consumer<CatchmentViewModel>(
                    builder: (context, catchmentViewModel, child) {
                      return Consumer<LotViewModel>(
                          builder: (context, lotViewModel, child) {
                            final isMapLoading = catchmentViewModel.isLoading ||
                                registerViewModel.isLoading ||
                                lotViewModel.isLoading ||
                                sectionViewModel.isLoading;
                            return Scaffold(
                              body: Row(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 0),
                                          width: !widget.isModal
                                              ? mapWidth - modalWidth
                                              : mapWidth,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: GoogleMap(
                                              mapType: _currentMapType,
                                              initialCameraPosition: CameraPosition(
                                                target: (location != null)
                                                    ? location!
                                                    : initLocation,
                                                zoom: zoomMap,
                                              ),
                                              markers: markers,
                                              onCameraMove: (
                                                  CameraPosition cameraPosition) {
                                                setState(() {
                                                  zoomMap = cameraPosition.zoom;
                                                });
                                              },
                                              onMapCreated: (
                                                  GoogleMapController controller) {
                                                if (location != null &&
                                                    _mapController
                                                        .isCompleted &&
                                                    !isMapLoading) {
                                                  controller.moveCamera(
                                                      CameraUpdate
                                                          .newLatLngZoom(
                                                          location!, zoomMap));
                                                }
                                                if (!_mapController
                                                    .isCompleted) {
                                                  _mapController.complete(
                                                      controller);
                                                }
                                              },
                                              onTap: (LatLng latLng) {
                                                if (locationManual) {
                                                  setState(() {
                                                    final Marker newMarker = Marker(
                                                      onTap: () {},
                                                      markerId: const MarkerId(
                                                          'tapped_location_manual'),
                                                      position: latLng,
                                                    );
                                                    markersGPS.clear();
                                                    markersGPS.add(newMarker);
                                                    _getMarkers();
                                                    location = LatLng(
                                                        latLng.latitude,
                                                        latLng.longitude);
                                                    selectedItemsProvider
                                                        .setInspectionPosition(
                                                        location!);
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        LoadingOverlay(
                                          isLoading: isMapLoading,
                                          child: Positioned(
                                            top: kIsWeb ? null : 80,
                                            right: kIsWeb ? null : 16,
                                            bottom: kIsWeb ? 80 : null,
                                            left: kIsWeb ? 16 : null,
                                            child: Column(
                                              children: [
                                                MenuElevatedButton(
                                                    onPressed: () {
                                                      markersGPS.clear();
                                                      getCurrentLocation();
                                                      _getMarkers();
                                                      setState(() {
                                                        locationManual = false;
                                                      });
                                                    },
                                                    icon: Icons.my_location,
                                                    tooltipMessage:
                                                    AppLocalizations.of(
                                                        context)!
                                                        .map_component_get_location),
                                                if (kIsWeb) const SizedBox(
                                                    height: 6),
                                                MenuElevatedButton(
                                                  colorChangeOnPress: true,
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedItemsProvider
                                                          .clearAll();
                                                      markersGPS.clear();
                                                      locationManual =
                                                      !locationManual;
                                                    });
                                                  },
                                                  colorSelected: redColor,
                                                  colorNotSelected: lightBackground,
                                                  tooltipMessage: AppLocalizations
                                                      .of(context)!
                                                      .map_component_select_location,
                                                  icon: Icons.location_pin,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    });
              });
        });
  }
}
