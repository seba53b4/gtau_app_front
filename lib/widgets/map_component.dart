import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/catchment_data.dart';
import 'package:gtau_app_front/models/register_data.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/register_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/enums/element_type.dart';
import '../models/section_data.dart';
import '../providers/user_provider.dart';
import '../utils/map_functions.dart';
import 'element_detail_modal.dart';
import 'element_detail_web.dart';

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
  Color selectedColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;
  Color selectedButtonColor = Colors.green;
  Color defaultButtonColor = Colors.primaries.first;
  bool locationManual = false;
  static const double zoom = 15;
  late Completer<GoogleMapController> _mapController;
  bool viewDetailElementInfo = false;
  double modalWidth = 300.0;
  late double mapWidth;
  late double mapInit;

  late int? elementSelectedId = null;
  late ElementType? elementSelectedType = null;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _mapController = Completer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapInit = MediaQuery.of(context).size.width;
    setState(() {
      mapWidth = mapInit;
    });
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

  Future<List<Section>?> fetchSectionsPolylines(String token) async {
    final sectionViewModel =
        Provider.of<SectionViewModel>(context, listen: false);
    LatLng? finalLocation = getFinalLocation();
    return await sectionViewModel.fetchSectionsByRadius(
        token,
        finalLocation!.latitude,
        finalLocation!.longitude,
        int.parse(distances[distanceSelected]));
  }

  Future<List<Catchment>?> fetchCatchmentsCircles(String token) async {
    final catchmentViewModel =
        Provider.of<CatchmentViewModel>(context, listen: false);

    LatLng? finalLocation = getFinalLocation();
    return await catchmentViewModel.fetchCatchmentsByRadius(
        token,
        finalLocation!.latitude,
        finalLocation!.longitude,
        int.parse(distances[distanceSelected]));
  }

  Future<List<Register>?> fetchRegistersCircles(String token) async {
    final registerViewModel =
        Provider.of<RegisterViewModel>(context, listen: false);

    LatLng? finalLocation = getFinalLocation();
    return await registerViewModel.fetchRegistersByRadius(
        token, finalLocation!.latitude, finalLocation!.longitude, 200);
  }

  LatLng? getFinalLocation() => (location != null) ? location : initLocation;

  Future<void> _onTapParamBehaviorSection(
      Section section, List<Section>? sections) async {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    if (selectedItemsProvider.letMultipleItemsSelected) {
      selectedItemsProvider.toggleSectionSelected(section.line!.polylineId);
    } else {
      if (!(selectedItemsProvider.isSomeCatchmentSelected() ||
          selectedItemsProvider.isSomeRegisterSelected())) {
        if (selectedItemsProvider.isSomeSectionSelected()) {
          selectedItemsProvider.toggleSectionSelected(section.line!.polylineId);
        } else {
          selectedItemsProvider.clearAllSelections();
          selectedItemsProvider.toggleSectionSelected(section.line!.polylineId);
          setState(() {
            elementSelectedId = section.ogcFid;
            elementSelectedType = ElementType.section;
            if (kIsWeb) {
              viewDetailElementInfo = true;
            }
          });
          if (kIsWeb) {
            await _fetchElementInfo();
          }
        }
      }
    }
  }

  Future<void> _onTapParamBehaviorCatchment(
      Catchment catchment, List<Catchment>? catchments) async {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    if (selectedItemsProvider.letMultipleItemsSelected) {
      selectedItemsProvider.toggleCatchmentSelected(catchment.point!.circleId);
    } else {
      if (!(selectedItemsProvider.isSomeSectionSelected() ||
          selectedItemsProvider.isSomeRegisterSelected())) {
        if (selectedItemsProvider.isSomeCatchmentSelected()) {
          selectedItemsProvider
              .toggleCatchmentSelected(catchment.point!.circleId);
        } else {
          selectedItemsProvider.clearAllSelections();
          selectedItemsProvider
              .toggleCatchmentSelected(catchment.point!.circleId);
          setState(() {
            elementSelectedId = catchment.ogcFid;
            elementSelectedType = ElementType.catchment;
            if (kIsWeb) {
              viewDetailElementInfo = true;
            }
          });
          if (kIsWeb) {
            await _fetchElementInfo();
          }
        }
      }
    }
  }

  bool isSomeElementSelected() {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isSomeElementSelected();
  }

  Future<void> _onTapParamBehaviorRegister(
      Register register, List<Register>? registers) async {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    if (selectedItemsProvider.letMultipleItemsSelected) {
      selectedItemsProvider.toggleRegistroSelected(register.point!.circleId);
    } else {
      if (!(selectedItemsProvider.isSomeCatchmentSelected() ||
          selectedItemsProvider.isSomeSectionSelected())) {
        if (selectedItemsProvider.isSomeRegisterSelected()) {
          selectedItemsProvider
              .toggleRegistroSelected(register.point!.circleId);
        } else {
          selectedItemsProvider.clearAllSelections();
          selectedItemsProvider
              .toggleRegistroSelected(register.point!.circleId);
          setState(() {
            elementSelectedId = register.ogcFid;
            elementSelectedType = ElementType.register;
            if (kIsWeb) {
              viewDetailElementInfo = true;
            }
          });
          if (kIsWeb) {
            await _fetchElementInfo();
          }
        }
      }
    }
  }

  Future _fetchElementInfo() async {
    if (elementSelectedType != null && elementSelectedId != null) {
      final token = context.read<UserProvider>().getToken;
      final catchmentViewModel = context.read<CatchmentViewModel>();
      final registerViewModel = context.read<RegisterViewModel>();
      final sectionViewModel = context.read<SectionViewModel>();
      switch (elementSelectedType) {
        case ElementType.catchment:
          await catchmentViewModel.fetchCatchmentById(
              token!, elementSelectedId!);
          break;
        case ElementType.register:
          await registerViewModel.fetchRegisterById(token!, elementSelectedId!);
          break;
        case ElementType.section:
          await sectionViewModel.fetchSectionById(token!, elementSelectedId!);
          break;
        default:
          throw Exception('Invalid status string: $elementSelectedId');
      }
    }
  }

  Color _onColorParamBehaviorSection(Section section) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isSectionSelected(section.line!.polylineId)
        ? selectedColor
        : section.line!.color;
  }

  Color _onColorParamBehaviorCatchment(Catchment catchment) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isCatchmentSelected(catchment.point!.circleId)
        ? selectedColor
        : catchment.point!.strokeColor;
  }

  Color _onColorParamBehaviorRegister(Register register) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    return selectedItemsProvider.isRegistroSelected(register.point!.circleId)
        ? selectedColor
        : register.point!.strokeColor;
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
        Polyline pol = section.line!.copyWith(
          colorParam: _onColorParamBehaviorSection(section),
          onTapParam: () async {
            await _onTapParamBehaviorSection(section, sections);
            setState(() {
              polylines = getPolylines(sections);
            });
          },
        );
        setPol.add(pol);
        setPol.addAll(
            polylineArrows(section.line!.points, section.line!.polylineId));
      }
      return setPol;
    } else {
      return {};
    }
  }

  Set<Circle> getCircles(
      List<Catchment>? catchments, List<Register>? registers) {
    Set<Circle> setCir = {};
    if (catchments != null) {
      for (var catchment in catchments) {
        Circle circle = catchment.point!.copyWith(
          centerParam: catchment.point!.center,
          radiusParam: catchment.point!.radius,
          strokeWidthParam: catchment.point!.strokeWidth,
          strokeColorParam: _onColorParamBehaviorCatchment(catchment),
          onTapParam: () async {
            await _onTapParamBehaviorCatchment(catchment, catchments);
            setState(() {
              circles = getCircles(catchments, registers);
            });
          },
        );
        setCir.add(circle);
      }
    }
    if (registers != null) {
      for (var register in registers) {
        Circle circle = register.point!.copyWith(
          centerParam: register.point!.center,
          radiusParam: register.point!.radius,
          strokeWidthParam: register.point!.strokeWidth,
          strokeColorParam: _onColorParamBehaviorRegister(register),
          onTapParam: () async {
            await _onTapParamBehaviorRegister(register, registers);
            setState(() {
              circles = getCircles(catchments, registers);
            });
          },
        );
        setCir.add(circle);
      }
      return setCir;
    } else {
      return {};
    }
  }

  Future fetchAndUpdateData(String token) async {
    List<Section>? fetchedSections = await fetchSectionsPolylines(token);
    List<Register>? fetchedRegisters = await fetchRegistersCircles(token);
    List<Catchment>? fetchedCatchments = await fetchCatchmentsCircles(token);

    setState(() {
      polylines = getPolylines(fetchedSections);
      circles = getCircles(fetchedCatchments, fetchedRegisters);
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().getToken;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  width: viewDetailElementInfo && !widget.isModal
                      ? mapWidth - modalWidth
                      : mapWidth,
                  child: GoogleMap(
                    mapType: _currentMapType,
                    initialCameraPosition: const CameraPosition(
                      target: initLocation,
                      zoom: zoom,
                    ),
                    polylines: polylines,
                    circles: circles,
                    markers: markers,
                    myLocationEnabled: true,
                    mapToolbarEnabled: true,
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
                      if (kIsWeb) const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () async {
                          await fetchAndUpdateData(token!);
                        },
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .map_component_fetch_elements,
                          preferBelow: false,
                          verticalOffset: 14,
                          waitDuration: Duration(milliseconds: 1000),
                          child: const Icon(
                            Icons.area_chart_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (kIsWeb) SizedBox(height: 6),
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
                          waitDuration: Duration(milliseconds: 1000),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (kIsWeb) SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: locationManual
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
                      if (kIsWeb) const SizedBox(height: 6),
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
                          child: Text(distances[distanceSelected]),
                        ),
                      ),
                      if (!kIsWeb)
                        ElevatedButton(
                          child: Text('Detail'),
                          onPressed: () async {
                            if (isSomeElementSelected() &&
                                elementSelectedType != null) {
                              showElementModal(
                                context,
                                elementSelectedType!,
                                () {},
                              );
                              await _fetchElementInfo();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (elementSelectedType != null && elementSelectedId != null)
            Visibility(
              visible: kIsWeb && !widget.isModal && viewDetailElementInfo,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  onEnd: () {},
                  curve: Curves.easeIn,
                  width: viewDetailElementInfo ? modalWidth : 0,
                  child: Container(
                    width: viewDetailElementInfo ? modalWidth : 0,
                    color: const Color.fromRGBO(253, 255, 252, 1),
                    child: Column(
                      children: [
                        ElementDetailWeb(
                          elementType: elementSelectedType,
                          onPressed: () {
                            setState(() {
                              viewDetailElementInfo = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
