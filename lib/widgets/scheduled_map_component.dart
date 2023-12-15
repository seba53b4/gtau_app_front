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
import 'common/button_circle.dart';
import 'common/menu_button_map.dart';
import 'common/menu_button_map_options.dart';
import 'common/scheduled_form_widget.dart';
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
    mapInit = MediaQuery.of(context).size.width;
    setState(() {
      mapWidth = mapInit;
    });
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

  void _onTapParamBehaviorPolyline(int ogcFid, Polyline? line) {
    if (kIsWeb) {
      setState(() {
        elementId = ogcFid;
        elementType = ElementType.section;
        viewDetailElementInfo = true;
      });
    } else {
      _showModalElement(context, ogcFid, ElementType.section);
    }
  }

  Future<void> _onTapParamBehaviorCircle(
      int ogcFid, Circle? point, ElementType type) async {
    if (kIsWeb) {
      setState(() {
        elementId = ogcFid;
        elementType = type;
        viewDetailElementInfo = true;
      });
    } else {
      _showModalElement(context, ogcFid, type);
    }
  }

  void _showModalElement(BuildContext context, int ogcFid, ElementType type) {
    showScheduledElementModal(context, type, () {}, widget.idSheduled, ogcFid);
  }

  Future<void> updateElementsOnMap(
      {bool isCache = false, ScheduledElements? scheduledElements}) async {
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

    scheduledViewModel.setInitPosition(
        getRandomPointOfMap(polylines, circles) ?? initLocation);

    setState(() {
      location = scheduledViewModel.initPosition;
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
                catchment.ogcFid!, catchment.point, ElementType.catchment);
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
                                    setState(() {
                                      viewDetailElementInfo = false;
                                    });
                                  }),
                              Container(
                                width: 250,
                                padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .component_detail_title,
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
                                  onAccept: () {
                                    setState(() {
                                      viewDetailElementInfo = false;
                                    });
                                  },
                                  onCancel: () {
                                    setState(() {
                                      viewDetailElementInfo = false;
                                    });
                                  },
                                  elementType: elementType,
                                  elementId: elementId,
                                  scheduledid: widget.idSheduled)),
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
