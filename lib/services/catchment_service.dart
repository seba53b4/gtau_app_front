import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:http/http.dart' as http;

import '../models/catchment_data.dart';
import '../utils/common_utils.dart';

class CatchmentService {
  final String baseUrl;
  static const sourcePath = 'captaciones';

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
          '$baseUrl/$sourcePath/searchOnRadius?=origin_longitude=$longitude&origin_latitude=$latitude&radius_mtr=$radiusMtr');
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
              consumeTapEvents: true,
              strokeColor: catchmentDefaultColor,
              fillColor: Colors.black);

          return Catchment(
              ogcFid: catchment['ogcFid'],
              tipo: catchment['tipo'],
              tipoboca: catchment['tipBoca'],
              point: circle);
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      printOnDebug('Error al obtener captaciones: $error');
      rethrow;
    }
  }

  Future<Catchment?> fetchCatchmentById(String token, int catchmentId) async {
    try {
      final url = Uri.parse('$baseUrl/$sourcePath/$catchmentId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Catchment(
          ogcFid: jsonResponse['ogcFid'],
          gid: jsonResponse['gid'],
          elemRed: jsonResponse['elemred'],
          tipo: jsonResponse['tipo'],
          tipoboca: jsonResponse['tipoboca'],
          datoObra: jsonResponse['datoObra'],
          lonC: jsonResponse['lonc'],
          latC: jsonResponse['latc'],
          fact: jsonResponse['fact'] != null
              ? DateTime.parse(jsonResponse['fact'])
              : null,
          fcrea: jsonResponse['fcrea'] != null
              ? DateTime.parse(jsonResponse['fcrea'])
              : null,
          idauditori: jsonResponse['idauditori'],
          uact: jsonResponse['uact'],
          ucrea: jsonResponse['ucrea'],
          point: Circle(circleId: CircleId(['ogcFid'].toString())),
        );
      } else {
        return null;
      }
    } catch (error) {
      printOnDebug('Error al obtener registros: $error');
      rethrow;
    }
  }
}
