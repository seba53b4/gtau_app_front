import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


import '../models/section_data.dart';


class SectionService {
  final String baseUrl;

  SectionService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Section>?> fetchSectionsByRadius(String token, double longitude, double latitude, int radiusMtr) async {
    try {

      final url = Uri.parse('$baseUrl/tramos/searchOnRadius?=origin_longitude=$longitude&origin_latitude=$latitude&radius_mtr=$radiusMtr');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse.map<Section>((section) {
          Map<String, dynamic> geoJson = section['geoJSON'];
          List<dynamic> multiLineCoordinates = geoJson['coordinates'];

          List<LatLng> latLngList = [];

          for (var coordinatesList in multiLineCoordinates) {
            for (var coord in coordinatesList) {
              double latitude = coord[1];
              double longitude = coord[0];
              latLngList.add(LatLng(latitude, longitude));
            }
          }

          Polyline polyline = Polyline(
            polylineId: PolylineId(section.hashCode.toString()),
            points: latLngList,
            color: Colors.red,
            width: 5,
            consumeTapEvents: true
          );

          return Section(line: polyline);
        }).toList();

      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener tramos: $error');
      }
      rethrow;
    }
  }

}
