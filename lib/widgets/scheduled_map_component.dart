import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/scheduled/catchment_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../models/enums/element_type.dart';
import '../models/scheduled/register_scheduled.dart';
import '../providers/user_provider.dart';
import '../services/scheduled_service.dart';
import '../utils/map_functions.dart';
import '../viewmodels/scheduled_viewmodel.dart';
import 'common/menu_button_map.dart';
import 'common/menu_button_map_options.dart';
import 'element_scheduled_modal.dart';

class ScheduledMapComponent extends StatefulWidget {
  final int idSheduled;

  const ScheduledMapComponent({super.key, required this.idSheduled});

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
  double zoomMap = 16;
  late Completer<GoogleMapController> _mapController;
  late SelectedItemsProvider selectedItemsProvider;
  late String token;
  bool isDetailsButtonVisible = false;
  late ScheduledViewModel scheduledViewModel;

  // Indices { S, R, C };
  Set<int> selectedIndices = {0, 1, 2};

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
    selectedItemsProvider = context.read<SelectedItemsProvider>();
    scheduledViewModel = context.read<ScheduledViewModel>();
    token = context.read<UserProvider>().getToken!;
    _initializeSheduledElements().then((value) => null);
  }

  @override
  void dispose() {
    super.dispose();
    selectedItemsProvider.reset();
  }

  Future<void> _initializeSheduledElements() async {
    ScheduledElements? entities = await scheduledViewModel
        .fetchScheduledElements(token, widget.idSheduled);
    if (entities != null) {
      updateElementsOnMap(isCache: false, scheduledElements: entities);
    }
  }

  Color _onColorParamBehaviorSection(SectionScheduled section) {
    return selectedItemsProvider.isPolylineSelected(
            section.line!.polylineId, ElementType.section)
        ? selectedColor
        : section.line!.color;
  }

  Color _onColorParamBehaviorCatchment(CatchmentScheduled catchment) {
    return selectedItemsProvider.isCircleSelected(
            catchment.point!.circleId, ElementType.catchment)
        ? selectedColor
        : catchment.point!.strokeColor;
  }

  Color _onColorParamBehaviorRegister(RegisterScheduled register) {
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

  void _clearMarkersGPS() {
    setState(() {
      markersGPS.clear();
    });
  }

  void _onTapParamBehaviorPolyline(int ogcFid, Polyline? line) {
    _showModalElement(context, ogcFid, ElementType.section);
  }

  Future<void> _onTapParamBehaviorCircle(
      int ogcFid, Circle? point, ElementType type) async {
    _showModalElement(context, ogcFid, type);
  }

  void _showModalElement(BuildContext context, int ogcFid, ElementType type) {
    showScheduledElementModal(context, type, () {}, widget.idSheduled, ogcFid);
  }

  void updateElementsOnMap(
      {bool isCache = false, ScheduledElements? scheduledElements}) {
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
      circles = getCircles(catchments, registers);
    });
  }

  Set<Polyline> getPolylines(List<SectionScheduled>? sections) {
    Set<Polyline> setPol = {};

    if (sections != null) {
      for (var section in sections) {
        Polyline pol = section.line!.copyWith(
          zIndexParam: 0,
          colorParam: _onColorParamBehaviorSection(section),
          onTapParam: () {
            _onTapParamBehaviorPolyline(section.ogcFid!, section.line);
            //updateElementsOnMap();
          },
        );
        setPol.add(pol);
        setPol.addAll(
            polylineArrows(section.line!.points, section.line!.polylineId));
      }
    }
    return setPol;
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
            await _onTapParamBehaviorCircle(
                catchment.ogcFid, catchment.point, ElementType.catchment);
            //updateElementsOnMap();
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
                register.ogcFid!, register.point, ElementType.register);
            //updateElementsOnMap();
          },
        );
        setCir.add(circle);
      }
    }
    return setCir;
  }

  // List<Future> getElementFutureSelected(String token) {
  //   List<Future> futures = [];
  //   // Agregar tramos a búsqueda
  //   if (selectedIndices.contains(0)) {
  //     futures.add(fetchSectionsPolylines(token));
  //   }
  //   // Agregar tramos a búsqueda
  //   if (selectedIndices.contains(1)) {
  //     futures.add(fetchRegistersCircles(token));
  //   }
  //   // Agregar tramos a búsqueda
  //   if (selectedIndices.contains(2)) {
  //     futures.add(fetchCatchmentsCircles(token));
  //   }
  //   if (selectedIndices.contains(3)) {
  //     //lo mismo pero para parcela
  //     futures.add(fetchLotsPolylines(token));
  //   }
  //   return futures;
  // }
  //
  // Future<void> fetchAndUpdateData(String token) async {
  //   List<Section>? fetchedSections;
  //   List<Register>? fetchedRegisters;
  //   List<Catchment>? fetchedCatchments;
  //   List<Lot>? fetchedLots;
  //
  //   List<Future> futuresElementsSelected = getElementFutureSelected(token);
  //   await Future.wait(futuresElementsSelected).then((responses) {
  //     int iter = 0;
  //     if (selectedIndices.contains(0)) {
  //       fetchedSections = responses[iter]?.cast<Section>();
  //       iter++;
  //     }
  //     if (selectedIndices.contains(1)) {
  //       fetchedRegisters = responses[iter]?.cast<Register>();
  //       iter++;
  //     }
  //     if (selectedIndices.contains(2)) {
  //       fetchedCatchments = responses[iter]?.cast<Catchment>();
  //       iter++;
  //     }
  //     if (selectedIndices.contains(3)) {
  //       fetchedLots = responses[iter]?.cast<Lot>();
  //       iter++;
  //     }
  //   }).catchError((error) async {
  //     // Manejo de error
  //     await showCustomMessageDialog(
  //       context: context,
  //       onAcceptPressed: () {},
  //       customText: AppLocalizations.of(context)!.error_generic_text,
  //       messageType: DialogMessageType.error,
  //     );
  //   });
  //
  //   setState(() {
  //     circles = getCircles(fetchedCatchments, fetchedRegisters);
  //     polylines = getPolylines(fetchedSections, fetchedLots);
  //   });
  // }

  void handleIconsSelected(Set<int> indices) {
    setState(() {
      selectedIndices = indices;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    //width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: () {},
                      child: GoogleMap(
                        mapType: _currentMapType,
                        initialCameraPosition: CameraPosition(
                          target: (location != null) ? location! : initLocation,
                          zoom: zoomMap,
                        ),
                        onCameraMove: (CameraPosition cameraPosition) {
                          setState(() {
                            zoomMap = cameraPosition.zoom;
                          });
                        },
                        circles: circles,
                        polylines: polylines,
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
                    left: 16.0,
                    top: 16.0,
                    child: FloatingActionButton(
                      foregroundColor: primarySwatch,
                      backgroundColor: lightBackground,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Retroceder',
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  LoadingOverlay(
                    isLoading: isLoading,
                    child: Positioned(
                      top: kIsWeb ? null : 80,
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
                            tooltipMessage: AppLocalizations.of(context)!
                                .map_component_map_view_tooltip,
                            icon: _currentMapType == MapType.normal
                                ? Icons.map
                                : Icons.satellite,
                          ),
                          if (kIsWeb) const SizedBox(height: 6),
                          MenuElevatedButton(
                              onPressed: () {},
                              icon: Icons.my_location,
                              tooltipMessage: AppLocalizations.of(context)!
                                  .map_component_get_location),
                          if (kIsWeb) const SizedBox(height: 6),
                          MultiSelectPopupMenuButton(
                            texts: [
                              AppLocalizations.of(context)!.sections,
                              AppLocalizations.of(context)!.registers,
                              AppLocalizations.of(context)!.catchments
                            ],
                            selectedIndices: selectedIndices,
                            onIconsSelected: handleIconsSelected,
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
  }
}
