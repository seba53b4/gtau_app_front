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
import 'package:gtau_app_front/viewmodels/lot_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/register_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';
import '../models/enums/element_type.dart';
import '../models/lot_data.dart';
import '../models/section_data.dart';
import '../providers/user_provider.dart';
import '../utils/map_functions.dart';
import 'common/customMessageDialog.dart';
import 'common/menu_button_map.dart';
import 'common/menu_button_map_options.dart';
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
  int lastDistanceSelected = 8;
  LatLng? lastLocation;
  MapType _currentMapType = MapType.hybrid;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Marker> markersGPS = {};
  bool isSectionDetailsVisible = false;
  Color selectedColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;
  Color selectedButtonColor = Colors.green;
  bool locationManual = false;
  bool locationManualSelected = false;
  double zoomMap = 16;
  late Completer<GoogleMapController> _mapController;
  bool viewDetailElementInfo = false;
  double modalWidth = 320.0;
  late double mapWidth;
  late double mapInit;
  late SelectedItemsProvider selectedItemsProvider;
  late SectionViewModel sectionViewModel;
  late LotViewModel lotViewModel;
  late CatchmentViewModel catchmentViewModel;
  late RegisterViewModel registerViewModel;
  late String token;
  bool isDetailsButtonVisible = false;

  // Indices { S, R, C, P};
  Set<int> selectedIndices = {0, 1, 2, 3};

  late int? elementSelectedId = null;
  late ElementType? elementSelectedType = null;

  @override
  void initState() {
    super.initState();
    _mapController = Completer<GoogleMapController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapInit = MediaQuery.of(context).size.width;
    setState(() {
      mapWidth = mapInit;
    });
    selectedItemsProvider = context.read<SelectedItemsProvider>();
    sectionViewModel = Provider.of<SectionViewModel>(context, listen: false);
    lotViewModel = Provider.of<LotViewModel>(context, listen: false);
    catchmentViewModel =
        Provider.of<CatchmentViewModel>(context, listen: false);
    registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);
    token = context.read<UserProvider>().getToken!;
    _initializeLocation();
    if (widget.isModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (sectionViewModel.hasSections() ||
            lotViewModel.hasLots() ||
            registerViewModel.hasRegisters() ||
            catchmentViewModel.hasCatchment()) {
          updateElementsOnMap();
        } else {
          LatLng? loc = getFinalLocation();
          if (loc != initLocation) {
            fetchAndUpdateData().then((value) => null);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    if (!widget.isModal) {
      selectedItemsProvider.reset();
    }
    if (!widget.isModal || locationManualSelected) {
      clearElementsFetched();
    }
    super.dispose();
  }

  void clearElementsFetched() {
    registerViewModel.reset();
    sectionViewModel.reset();
    lotViewModel.reset();
    catchmentViewModel.reset();
  }

  Future<void> _initializeLocation() async {
    try {
      if (selectedItemsProvider.inspectionPosition.latitude == 0 &&
          selectedItemsProvider.inspectionPosition.longitude == 0) {
        if (!kIsWeb) getCurrentLocation();
      } else {
        setState(() {
          final locationGPS = selectedItemsProvider.inspectionPosition;
          lastLocation = locationGPS;
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
        lastLocation = locationGPS;
        final Marker newMarker = Marker(
          markerId: const MarkerId('current_gps_location'),
          position: locationGPS,
        );
        location = locationGPS;
        markersGPS.add(newMarker);
        _getMarkers();
      });
      if (currentPosition.latitude != initLocation.latitude &&
          currentPosition.longitude != initLocation.longitude) {
        selectedItemsProvider.setInspectionPosition(
            LatLng(currentPosition.latitude, currentPosition.longitude));
      }
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

  Future<List<Section>?> fetchSectionsPolylines() async {
    LatLng? finalLocation = getFinalLocation();
    return await sectionViewModel.fetchSectionsByRadius(
        token,
        finalLocation!.latitude,
        finalLocation.longitude,
        int.parse(distances[distanceSelected]));
  }

  Future<List<Lot>?> fetchLotsPolylines() async {
    LatLng? finalLocation = getFinalLocation();
    return await lotViewModel.fetchLotsByRadius(token, finalLocation!.latitude,
        finalLocation.longitude, int.parse(distances[distanceSelected]));
  }

  Future<List<Catchment>?> fetchCatchmentsCircles() async {
    LatLng? finalLocation = getFinalLocation();
    return await catchmentViewModel.fetchCatchmentsByRadius(
        token,
        finalLocation!.latitude,
        finalLocation.longitude,
        int.parse(distances[distanceSelected]));
  }

  Future<List<Register>?> fetchRegistersCircles() async {
    LatLng? finalLocation = getFinalLocation();
    return await registerViewModel.fetchRegistersByRadius(
        token,
        finalLocation!.latitude,
        finalLocation.longitude,
        int.parse(distances[distanceSelected]));
  }

  LatLng? getFinalLocation() => (location != null) ? location : initLocation;

  Future<void> _onTapParamBehaviorPolyline(
      int ogcFid, Polyline? line, ElementType type) async {
    if (selectedItemsProvider.letMultipleItemsSelected) {
      selectedItemsProvider.togglePolylineSelected(line!.polylineId, type);
    } else {
      if (selectedItemsProvider.isPolylineSelected(line!.polylineId, type)) {
        selectedItemsProvider.togglePolylineSelected(line.polylineId, type);
        isDetailsButtonVisible = false;
        if (kIsWeb) {
          viewDetailElementInfo = false;
        }
      } else {
        selectedItemsProvider.clearAllElements();
        selectedItemsProvider.togglePolylineSelected(line.polylineId, type);
        setState(() {
          elementSelectedId = ogcFid;
          elementSelectedType = type;
          isDetailsButtonVisible = true;
          if (kIsWeb) {
            viewDetailElementInfo = true;
          }
        });
      }
      if (kIsWeb) {
        await _fetchElementInfo();
      }
    }
  }

  Future<void> _onTapParamBehaviorCircle(
      int ogcFid, Circle? point, ElementType type) async {
    if (selectedItemsProvider.letMultipleItemsSelected) {
      selectedItemsProvider.toggleCircleSelected(point!.circleId, type);
    } else {
      if (selectedItemsProvider.isCircleSelected(point!.circleId, type)) {
        selectedItemsProvider.toggleCircleSelected(point.circleId, type);
        isDetailsButtonVisible = false;
        if (kIsWeb) {
          viewDetailElementInfo = false;
        }
      } else {
        selectedItemsProvider.clearAllElements();
        selectedItemsProvider.toggleCircleSelected(point.circleId, type);
        setState(() {
          elementSelectedId = ogcFid;
          elementSelectedType = type;
          isDetailsButtonVisible = true;
          if (kIsWeb) {
            viewDetailElementInfo = true;
          }
        });
      }
      if (kIsWeb) {
        await _fetchElementInfo();
      }
    }
  }

  void updateElementsOnMap() {
    List<Section>? sections;
    List<Lot>? lots;
    List<Catchment>? catchments;
    List<Register>? registers;

    if (selectedIndices.contains(0)) {
      sections = sectionViewModel.sections;
    }

    if (selectedIndices.contains(1)) {
      registers = registerViewModel.registers;
    }

    if (selectedIndices.contains(2)) {
      catchments = catchmentViewModel.catchments;
    }
    if (selectedIndices.contains(3)) {
      lots = lotViewModel.lots;
    }

    setState(() {
      polylines = getPolylines(sections, lots);
      circles = getCircles(catchments, registers);
    });
  }

  bool isSomeElementSelected() {
    return selectedItemsProvider.isSomeElementSelected();
  }

  Future _fetchElementInfo() async {
    if (elementSelectedType != null && elementSelectedId != null) {
      switch (elementSelectedType) {
        case ElementType.catchment:
          await catchmentViewModel.fetchCatchmentById(
              token, elementSelectedId!);
          break;
        case ElementType.register:
          await registerViewModel.fetchRegisterById(token, elementSelectedId!);
          break;
        case ElementType.section:
          await sectionViewModel.fetchSectionById(token, elementSelectedId!);
          break;
        case ElementType.lot:
          await lotViewModel.fetchLotById(token, elementSelectedId!);
          break;
        default:
          throw Exception('Invalid status string: $elementSelectedId');
      }
    }
  }

  Color _onColorParamBehaviorSection(Section section) {
    return selectedItemsProvider.isPolylineSelected(
            section.line!.polylineId, ElementType.section)
        ? selectedColor
        : section.line!.color;
  }

  Color _onColorParamBehaviorLot(Lot lot) {
    return selectedItemsProvider.isPolylineSelected(
            lot.polyline!.polylineId, ElementType.lot)
        ? selectedColor
        : lot.polyline!.color;
  }

  Color _onColorParamBehaviorCatchment(Catchment catchment) {
    return selectedItemsProvider.isCircleSelected(
            catchment.point!.circleId, ElementType.catchment)
        ? selectedColor
        : catchment.point!.strokeColor;
  }

  Color _onColorParamBehaviorRegister(Register register) {
    return selectedItemsProvider.isCircleSelected(
            register.point!.circleId, ElementType.register)
        ? selectedColor
        : register.point!.strokeColor;
  }

  void _getMarkers() {
    setState(() {
      markers.clear();
      markers.addAll(markersGPS);
    });
  }

  Set<Polyline> getPolylines(List<Section>? sections, List<Lot>? lots) {
    Set<Polyline> setPol = {};

    if (sections != null) {
      for (var section in sections) {
        Polyline pol = section.line!.copyWith(
          zIndexParam: 0,
          colorParam: _onColorParamBehaviorSection(section),
          onTapParam: () async {
            await _onTapParamBehaviorPolyline(
                section.ogcFid, section.line, ElementType.section);
            updateElementsOnMap();
          },
        );
        setPol.add(pol);
        setPol.addAll(
            polylineArrows(section.line!.points, section.line!.polylineId));
      }
    }
    if (lots != null) {
      for (var lot in lots) {
        Polyline pol = lot.polyline!.copyWith(
          zIndexParam: 0,
          colorParam: _onColorParamBehaviorLot(lot),
          onTapParam: () async {
            await _onTapParamBehaviorPolyline(
                lot.ogcFid, lot.polyline, ElementType.lot);
            updateElementsOnMap();
          },
        );
        setPol.add(pol);
      }
    }

    return setPol;
  }

  Set<Circle> getCircles(
      List<Catchment>? catchments, List<Register>? registers) {
    Set<Circle> setCir = {};
    if (catchments != null) {
      for (var catchment in catchments) {
        Circle circle = catchment.point!.copyWith(
          zIndexParam: 1,
          centerParam: catchment.point!.center,
          radiusParam: catchment.point!.radius,
          strokeWidthParam: catchment.point!.strokeWidth,
          strokeColorParam: _onColorParamBehaviorCatchment(catchment),
          onTapParam: () async {
            await _onTapParamBehaviorCircle(
                catchment.ogcFid, catchment.point, ElementType.catchment);
            updateElementsOnMap();
          },
        );
        setCir.add(circle);
      }
    }
    if (registers != null) {
      for (var register in registers) {
        Circle circle = register.point!.copyWith(
          zIndexParam: 1,
          centerParam: register.point!.center,
          radiusParam: register.point!.radius,
          strokeWidthParam: register.point!.strokeWidth,
          strokeColorParam: _onColorParamBehaviorRegister(register),
          onTapParam: () async {
            await _onTapParamBehaviorCircle(
                register.ogcFid, register.point, ElementType.register);
            updateElementsOnMap();
          },
        );
        setCir.add(circle);
      }
    }
    return setCir;
  }

  void getElements() async {
    LatLng? finalLocation = getFinalLocation();
    if (lastDistanceSelected != distanceSelected ||
        finalLocation != lastLocation) {
      selectedIndices.addAll([0, 1, 2, 3]);
      await fetchAndUpdateData();
      setState(() {
        lastDistanceSelected = distanceSelected;
        lastLocation = finalLocation;
      });
    } else {
      updateElementsOnMap();
    }
  }

  List<Future> getElementFutureSelected() {
    List<Future> futures = [];
    // Agregar tramos a búsqueda
    if (selectedIndices.contains(0)) {
      futures.add(fetchSectionsPolylines());
    }
    // Agregar tramos a búsqueda
    if (selectedIndices.contains(1)) {
      futures.add(fetchRegistersCircles());
    }
    // Agregar tramos a búsqueda
    if (selectedIndices.contains(2)) {
      futures.add(fetchCatchmentsCircles());
    }
    if (selectedIndices.contains(3)) {
      //lo mismo pero para parcela
      futures.add(fetchLotsPolylines());
    }
    return futures;
  }

  Future<void> fetchAndUpdateData() async {
    List<Section>? fetchedSections;
    List<Register>? fetchedRegisters;
    List<Catchment>? fetchedCatchments;
    List<Lot>? fetchedLots;

    List<Future> futuresElementsSelected = getElementFutureSelected();
    await Future.wait(futuresElementsSelected).then((responses) {
      int iter = 0;
      if (selectedIndices.contains(0)) {
        fetchedSections = responses[iter]?.cast<Section>();
        iter++;
      }
      if (selectedIndices.contains(1)) {
        fetchedRegisters = responses[iter]?.cast<Register>();
        iter++;
      }
      if (selectedIndices.contains(2)) {
        fetchedCatchments = responses[iter]?.cast<Catchment>();
        iter++;
      }
      if (selectedIndices.contains(3)) {
        fetchedLots = responses[iter]?.cast<Lot>();
        iter++;
      }
    }).catchError((error) async {
      // Manejo de error
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {},
        customText: AppLocalizations.of(context)!.error_generic_text,
        messageType: DialogMessageType.error,
      );
    });

    setState(() {
      circles = getCircles(fetchedCatchments, fetchedRegisters);
      polylines = getPolylines(fetchedSections, fetchedLots);
    });
  }

  void handleIconsSelected(Set<int> indices) {
    setState(() {
      selectedIndices = indices;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          duration: const Duration(milliseconds: 0),
                          width: viewDetailElementInfo && !widget.isModal
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
                              polylines: polylines,
                              markers: markers,
                              circles: circles,
                              onCameraMove: (CameraPosition cameraPosition) {
                                setState(() {
                                  zoomMap = cameraPosition.zoom;
                                });
                              },
                              onMapCreated: (GoogleMapController controller) {
                                if (location != null &&
                                    _mapController.isCompleted &&
                                    !isMapLoading) {
                                  controller.moveCamera(
                                      CameraUpdate.newLatLngZoom(
                                          location!, zoomMap));
                                }
                                if (!_mapController.isCompleted) {
                                  _mapController.complete(controller);
                                }
                                controller.setMapStyle(customMapStyle);
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
                                        latLng.latitude, latLng.longitude);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        LoadingOverlay(
                          isLoading: isMapLoading && !viewDetailElementInfo,
                          child: Positioned(
                            top: kIsWeb ? null : 50,
                            right: kIsWeb ? null : 16,
                            bottom: kIsWeb ? 80 : null,
                            left: kIsWeb ? 16 : null,
                            child: Column(
                              children: [
                                MenuElevatedButton(
                                  colorChangeOnPress: true,
                                  onPressed: () {
                                    setState(() {
                                      _currentMapType =
                                          _currentMapType == MapType.hybrid
                                              ? MapType.normal
                                              : MapType.hybrid;
                                    });
                                  },
                                  tooltipMessage: AppLocalizations.of(context)!
                                      .map_component_map_view_tooltip,
                                  icon: _currentMapType == MapType.normal
                                      ? Icons.map
                                      : Icons.satellite,
                                ),
                                if (kIsWeb) const SizedBox(height: 6),
                                MenuElevatedButton(
                                  onPressed: () async {
                                    getElements();
                                  },
                                  tooltipMessage: AppLocalizations.of(context)!
                                      .map_component_fetch_elements,
                                  icon: Icons.area_chart_outlined,
                                ),
                                if (kIsWeb) const SizedBox(height: 6),
                                if (!kIsWeb)
                                  MenuElevatedButton(
                                      onPressed: () {
                                        markersGPS.clear();
                                        getCurrentLocation();
                                        _getMarkers();
                                        setState(() {
                                          polylines = {};
                                          circles = {};
                                        });
                                      },
                                      icon: Icons.my_location,
                                      tooltipMessage:
                                          AppLocalizations.of(context)!
                                              .map_component_get_location),
                                if (kIsWeb) const SizedBox(height: 6),
                                MenuElevatedButton(
                                  colorChangeOnPress: true,
                                  onPressed: () {
                                    setState(() {
                                      if (!widget.isModal) {
                                        selectedItemsProvider
                                            .clearAllElements();
                                      }
                                      locationManualSelected =
                                          locationManualSelected || true;
                                      isDetailsButtonVisible = false;
                                      markersGPS.clear();
                                      if (kIsWeb) {
                                        viewDetailElementInfo = false;
                                      }
                                      polylines = {};
                                      circles = {};
                                      locationManual = !locationManual;
                                    });
                                  },
                                  colorSelected: redColor,
                                  colorNotSelected: lightBackground,
                                  tooltipMessage: AppLocalizations.of(context)!
                                      .map_component_select_location,
                                  icon: Icons.location_pin,
                                ),
                                if (kIsWeb) const SizedBox(height: 6),
                                MenuElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      distanceSelected =
                                          (distanceSelected + 1) %
                                              distances.length;
                                    });
                                  },
                                  tooltipMessage: AppLocalizations.of(context)!
                                      .map_component_diameter_tooltip,
                                  text: distances[distanceSelected],
                                ),
                                if (kIsWeb) const SizedBox(height: 6),
                                MultiSelectPopupMenuButton(
                                  texts: [
                                    AppLocalizations.of(context)!.sections,
                                    AppLocalizations.of(context)!.registers,
                                    AppLocalizations.of(context)!.catchments,
                                    AppLocalizations.of(context)!.lots
                                  ],
                                  selectedIndices: selectedIndices,
                                  onIconsSelected: handleIconsSelected,
                                ),
                                if (kIsWeb) const SizedBox(height: 6),
                                Visibility(
                                  visible: isDetailsButtonVisible &&
                                      !kIsWeb &&
                                      !widget.isModal,
                                  child: MenuElevatedButton(
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
                                    icon: Icons.list_alt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (elementSelectedType != null && elementSelectedId != null)
                    Visibility(
                      visible:
                          kIsWeb && !widget.isModal && viewDetailElementInfo,
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
                                      selectedItemsProvider.clearAllElements();
                                      updateElementsOnMap();
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
          });
        });
      });
    });
  }
}
