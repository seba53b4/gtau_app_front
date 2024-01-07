import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/scheduled/catchment_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:gtau_app_front/widgets/radio_dropdown.dart';
import 'package:provider/provider.dart';

import '../models/enums/element_type.dart';
import '../models/scheduled/register_scheduled.dart';
import '../models/scheduled/zone.dart';
import '../providers/user_provider.dart';
import '../services/scheduled_service.dart';
import '../utils/map_functions.dart';
import '../viewmodels/scheduled_viewmodel.dart';
import 'common/button_circle.dart';
import 'common/customMessageDialog.dart';
import 'common/menu_button_map.dart';
import 'common/menu_button_map_options.dart';
import 'common/scheduled_form_widget.dart';
import 'element_scheduled_modal.dart';

class ScheduledMapComponent extends StatefulWidget {
  final int? idSheduled;
  final ScheduledZone? scheduledZone;

  const ScheduledMapComponent(
      {super.key, required this.idSheduled, this.scheduledZone});

  @override
  _ScheduledMapComponentState createState() => _ScheduledMapComponentState();
}

class _ScheduledMapComponentState extends State<ScheduledMapComponent> {
  LatLng? location;
  static const LatLng initLocation = LatLng(-34.88773, -56.13955);
  MapType _currentMapType = MapType.satellite;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Marker> markersGPS = {};
  bool isSectionDetailsVisible = false;
  Color selectedColor = Colors.greenAccent;
  Color defaultPolylineColor = Colors.redAccent;
  Color selectedButtonColor = Colors.green;
  bool locationManual = false;
  double zoomMap = 15.36;
  late Completer<GoogleMapController> _mapController;
  late SelectedItemsProvider selectedItemsProvider;
  late String token;
  bool isDetailsButtonVisible = false;
  late ScheduledViewModel scheduledViewModel;
  late double mapWidth;
  late double mapInit;
  double modalWidth = 380.0;
  bool viewDetailElementInfo = false;
  int elementId = -1;
  ElementType elementType = ElementType.section;
  Key _scheduledFormWidgetKey = UniqueKey();

  // Indices { S, R, C };
  Set<int> selectedIndices = {0, 1, 2};
  int selectedSubZone = 0;
  late int? elementSelectedId = null;
  late ElementType? elementSelectedType = null;

  @override
  void initState() {
    super.initState();
    _mapController = Completer<GoogleMapController>();
    selectedItemsProvider = context.read<SelectedItemsProvider>();
    scheduledViewModel = context.read<ScheduledViewModel>();
    token = context.read<UserProvider>().getToken!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapInit = MediaQuery.of(context).size.width;
    setState(() {
      mapWidth = mapInit;
    });
    bool isNewLocation = scheduledViewModel.positionToBeLoaded();
    _initializeSheduledElements(isNewLocation: isNewLocation)
        .then((value) => null);
  }

  @override
  void dispose() {
    super.dispose();
    selectedItemsProvider.reset();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
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
        markers.add(newMarker);
      });

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
      print(e.toString());
    }
  }

  Future<void> _initializeSheduledElements({bool isNewLocation = false}) async {
    if (kIsWeb) {
      ScheduledElements? entities = await scheduledViewModel
          .fetchScheduledElements(
              token: token,
              scheduledId: widget.idSheduled!,
              subzone: widget.scheduledZone!.subZones!
                  .elementAt(selectedSubZone)
                  .id!)
          .catchError((error) async {
        // Manejo de error
        await showCustomMessageDialog(
          context: context,
          onAcceptPressed: () {},
          customText: AppLocalizations.of(context)!.error_service_not_available,
          messageType: DialogMessageType.error,
        );
        return null;
      });
      if (entities != null) {
        await updateElementsOnMap(
            isCache: false,
            isNewLocation: isNewLocation,
            scheduledElements: entities);
      }
    }
  }

  Color _onColorParamBehaviorSection(SectionScheduled section) {
    if (selectedItemsProvider.isPolylineSelected(
        section.line!.polylineId, ElementType.section)) {
      return selectedColor;
    }
    return section.inspectioned
        ? scheduledInspectionedElement
        : scheduledNotInspectionedElement;
  }

  Color _onColorParamBehaviorCatchment(CatchmentScheduled catchment) {
    return _commonColorBehaviorOnCircle(catchment.point!.circleId,
        catchment.inspectioned, ElementType.catchment);
  }

  Color _onColorParamBehaviorRegister(RegisterScheduled register) {
    return _commonColorBehaviorOnCircle(
        register.point!.circleId, register.inspectioned, ElementType.register);
  }

  Color _commonColorBehaviorOnCircle(
      CircleId circleId, bool inspectioned, ElementType type) {
    if (selectedItemsProvider.isCircleSelected(circleId, type)) {
      return selectedColor;
    }
    return inspectioned
        ? scheduledInspectionedElement
        : scheduledNotInspectionedElement;
  }

  void _onTapParamBehaviorPolyline(int ogcFid, Polyline? line) {
    ElementType elementType = ElementType.section;
    if (selectedItemsProvider.isPolylineSelected(
        line!.polylineId, elementType)) {
      selectedItemsProvider.togglePolylineSelected(
          line.polylineId, elementType);
      openFormElementWeb(false);
      updateElementsOnMap();
    } else {
      if (selectedItemsProvider.isSomeElementSelected()) {
        selectedItemsProvider.clearAllElements();
        updateElementsOnMap();
      } else {
        selectedItemsProvider.clearAllElements();
      }
      selectedItemsProvider.togglePolylineSelected(
          line.polylineId, elementType);
      openFormElementWeb(false);
      showDetailElement(ogcFid, elementType);
    }
  }

  void _onTapParamBehaviorCircle(int ogcFid, Circle? point, ElementType type) {
    if (selectedItemsProvider.isCircleSelected(point!.circleId, type)) {
      selectedItemsProvider.toggleCircleSelected(point.circleId, type);
      openFormElementWeb(false);
      updateElementsOnMap();
    } else {
      if (selectedItemsProvider.isSomeElementSelected()) {
        selectedItemsProvider.clearAllElements();
        updateElementsOnMap();
      } else {
        selectedItemsProvider.clearAllElements();
      }
      selectedItemsProvider.toggleCircleSelected(point.circleId, type);
      openFormElementWeb(false);
      showDetailElement(ogcFid, type);
    }
  }

  void openFormElementWeb(bool newStatus) {
    if (kIsWeb && viewDetailElementInfo != newStatus) {
      setState(() {
        _scheduledFormWidgetKey = UniqueKey();
        viewDetailElementInfo = newStatus;
      });
    }
  }

  void showDetailElement(int id, ElementType type) {
    if (kIsWeb) {
      setState(() {
        elementId = id;
        elementType = type;
        openFormElementWeb(true);
      });
    } else {
      _showModalElement(context, id, type);
    }
  }

  void _showModalElement(BuildContext context, int ogcFid, ElementType type) {
    showScheduledElementModal(
      context: context,
      scheduledId: widget.idSheduled!,
      elementType: type,
      elementId: ogcFid,
      onAccept: () async {
        openFormElementWeb(false);
        resetSelectionsOnMap();
        await _initializeSheduledElements();
      },
      onCancel: () {
        openFormElementWeb(false);
        resetSelectionsOnMap();
      },
    );
  }

  Future<void> updateElementsOnMap(
      {bool isCache = true,
      bool isNewLocation = false,
      ScheduledElements? scheduledElements}) async {
    List<SectionScheduled>? sections;
    List<RegisterScheduled>? registers;
    List<CatchmentScheduled>? catchments;

    if (isCache) {
      sections = scheduledViewModel.sections;
      catchments = scheduledViewModel.catchments;
      registers = scheduledViewModel.registers;
    } else {
      sections = scheduledElements?.sections;
      catchments = scheduledElements?.catchments;
      registers = scheduledElements?.registers;
    }
    setState(() {
      polylines = getPolylines(sections);
      polylines.addAll(getPolylinesSubZone());
      circles = getCircles(catchments, registers);
    });

    if (isNewLocation) {
      await scheduledViewModel.getRandomPosition(polylines, circles);
    }
    setState(() {
      location = scheduledViewModel.getPosition();
    });

    final GoogleMapController controller = await _mapController.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location!.latitude, location!.longitude),
          zoom: zoomMap,
        ),
      ),
    );
  }

  void updateElementsOnMapOnFilter() {
    List<SectionScheduled>? sectionsFilter = [];
    List<CatchmentScheduled>? catchmentsFilter = [];
    List<RegisterScheduled>? registersFilter = [];

    if (selectedIndices.contains(0)) {
      sectionsFilter = scheduledViewModel.sections;
    }

    if (selectedIndices.contains(1)) {
      registersFilter = scheduledViewModel.registers;
    }

    if (selectedIndices.contains(2)) {
      catchmentsFilter = scheduledViewModel.catchments;
    }

    setState(() {
      polylines = getPolylines(sectionsFilter);
      polylines.addAll(getPolylinesSubZone());
      circles = getCircles(catchmentsFilter, registersFilter);
    });
  }

  void resetSelectionsOnMap() async {
    if (selectedItemsProvider.isSomeElementSelected()) {
      selectedItemsProvider.clearAllElements();
      await updateElementsOnMap();
    }
  }

  Set<Polyline> getPolylines(List<SectionScheduled>? sections) {
    Set<Polyline> setPol = {};

    if (sections != null) {
      for (var section in sections) {
        Polyline pol = section.line!.copyWith(
          zIndexParam: 0,
          colorParam: _onColorParamBehaviorSection(section),
          onTapParam: () async {
            _onTapParamBehaviorPolyline(section.ogcFid!, section.line);
            await updateElementsOnMap();
          },
        );
        setPol.add(pol);
        setPol.addAll(
            polylineArrows(section.line!.points, section.line!.polylineId));
      }
    }
    return setPol;
  }

  Set<Polyline> getPolylinesSubZone() {
    return Set<Polyline>.from(
        widget.scheduledZone!.subZones!.elementAt(selectedSubZone).polylines);
  }

  Set<Circle> getCircles(List<CatchmentScheduled>? catchments,
      List<RegisterScheduled>? registers) {
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
            _onTapParamBehaviorCircle(
                catchment.ogcFid!, catchment.point, ElementType.catchment);
            await updateElementsOnMap();
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
            _onTapParamBehaviorCircle(
                register.ogcFid!, register.point, ElementType.register);
            await updateElementsOnMap();
          },
        );
        setCir.add(circle);
      }
    }
    return setCir;
  }

  void handleIconsSelected(Set<int> indices) {
    setState(() {
      selectedIndices = indices;
    });
  }

  void handleZoneIconSelected(int value) {
    setState(() {
      selectedSubZone = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<ScheduledViewModel>(
        builder: (context, scheduledViewModel, child) {
      bool isLoading = scheduledViewModel.isLoading;
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    width: viewDetailElementInfo
                        ? mapWidth - modalWidth
                        : mapWidth,
                    child: GestureDetector(
                      onTap: () {},
                      child: GoogleMap(
                        mapType: _currentMapType,
                        initialCameraPosition: CameraPosition(
                          target: initLocation,
                          zoom: zoomMap,
                        ),
                        onCameraMove: (CameraPosition cameraPosition) {
                          setState(() {
                            zoomMap = cameraPosition.zoom;
                          });
                        },
                        circles: circles,
                        polylines: polylines,
                        markers: markers,
                        onMapCreated: (GoogleMapController controller) {
                          if (location != null &&
                              _mapController.isCompleted &&
                              !(false)) {
                            controller.moveCamera(
                                CameraUpdate.newLatLngZoom(location!, zoomMap));
                          }
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
                        },
                        onTap: (LatLng latLng) {},
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: MediaQuery.of(context).size.width / 2 - 180,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24.0),
                            bottomRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Text(
                          '${widget.scheduledZone!.name} - ${widget.scheduledZone!.subZones!.elementAt(selectedSubZone).cuenca}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.0,
                    top: 50,
                    bottom: null,
                    right: null,
                    child: MenuElevatedButton(
                      colorChangeOnPress: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltipMessage: appLocalizations.placeholder_back_button,
                      icon: Icons.arrow_back,
                    ),
                  ),
                  LoadingOverlay(
                    isLoading: isLoading,
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
                                    _currentMapType == MapType.normal
                                        ? MapType.satellite
                                        : MapType.normal;
                              });
                            },
                            tooltipMessage:
                                appLocalizations.map_component_map_view_tooltip,
                            icon: _currentMapType == MapType.normal
                                ? Icons.map
                                : Icons.satellite,
                          ),
                          if (kIsWeb) const SizedBox(height: 6),
                          MenuElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  markers.clear();
                                });
                                await getCurrentLocation();
                              },
                              icon: Icons.my_location,
                              tooltipMessage:
                                  appLocalizations.map_component_get_location),
                          if (kIsWeb) const SizedBox(height: 6),
                          MultiSelectPopupMenuButton(
                            texts: [
                              appLocalizations.sections,
                              appLocalizations.registers,
                              appLocalizations.catchments
                            ],
                            onClose: () {
                              updateElementsOnMapOnFilter();
                            },
                            selectedIndices: selectedIndices,
                            onIconsSelected: handleIconsSelected,
                          ),
                          if (kIsWeb) const SizedBox(height: 6),
                          SingleSelectDropdown(
                            onChanged: (int value) {
                              handleZoneIconSelected(value);
                            },
                            onClose: () async {
                              Future.delayed(const Duration(milliseconds: 400));
                              await _initializeSheduledElements(
                                  isNewLocation: true);
                            },
                            icon: Icons.map_outlined,
                            items: widget.scheduledZone!.subZones!.map((e) {
                              return e.cuenca!;
                            }).toList(),
                            selectedItemIndex: selectedSubZone,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: kIsWeb && viewDetailElementInfo,
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
                        Container(
                          color: primarySwatch,
                          height: 50,
                          child: Row(
                            children: [
                              ButtonCircle(
                                  icon: Icons.close,
                                  size: 50,
                                  onPressed: () {
                                    openFormElementWeb(false);
                                    resetSelectionsOnMap();
                                  }),
                              Container(
                                width: 250,
                                padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    appLocalizations.component_detail_title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: titleColor,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: ScheduledFormWidget(
                                  key: _scheduledFormWidgetKey,
                                  onAccept: () async {
                                    openFormElementWeb(false);
                                    resetSelectionsOnMap();
                                    await _initializeSheduledElements();
                                  },
                                  onCancel: () {
                                    openFormElementWeb(false);
                                    resetSelectionsOnMap();
                                  },
                                  elementType: elementType,
                                  elementId: elementId,
                                  scheduledid: widget.idSheduled!)),
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
  }
}
