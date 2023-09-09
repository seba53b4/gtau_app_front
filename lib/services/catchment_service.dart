import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/catchment_data.dart';

class CatchmentService {
  final String baseUrl;

  CatchmentService({String? baseUrl})
      : baseUrl =
            baseUrl ?? dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Catchment>?> fetchCatchmentsByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      final url = Uri.parse(
          '$baseUrl/captaciones/searchOnRadius?=origin_longitude=$longitude&origin_latitude=$latitude&radius_mtr=$radiusMtr');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse.map<Catchment>((catchment) {
          Map<String, dynamic> geoJson = catchment['geoJSON'];
          List<dynamic> coordenates = geoJson['coordinates'];

          double latitude = coordenates[1];
          double longitude = coordenates[0];
          LatLng latLngCenter = LatLng(latitude, longitude);

          Circle circle = Circle(
              circleId: CircleId(catchment['ogcFid'].toString()),
              center: latLngCenter,
              radius: 2,
              strokeWidth: 2,
              strokeColor: Colors.pink,
              fillColor: Colors.black);

          return Catchment(ogcFid: catchment['ogcFid'], point: circle);
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener captaciones: $error');
      }
      rethrow;
    }
  }
}
