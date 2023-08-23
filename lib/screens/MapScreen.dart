

import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/map_component.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: MapComponent(),
    );

  }
}
