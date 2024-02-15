import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants/theme_constants.dart';
import '../models/register_data.dart';
import '../utils/common_utils.dart';

class RegisterService {
  final String baseUrl;
  static const String sourcePath = 'registros';

  RegisterService({String? baseUrl})
      : baseUrl =
            baseUrl ?? dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Register>?> fetchRegistersByRadius(
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
        return jsonResponse.map<Register>((register) {
          Map<String, dynamic> geoJson = register['geoJSON'];
          List<dynamic> coordenates = geoJson['coordinates'];

          double latitude = coordenates[1];
          double longitude = coordenates[0];
          LatLng latLngCenter = LatLng(latitude, longitude);

          Circle circle = Circle(
              circleId: CircleId(register['ogcFid'].toString()),
              center: latLngCenter,
              radius: 1.3,
              strokeWidth: 7,
              consumeTapEvents: true,
              strokeColor: registerDefaultColor,
              fillColor: Colors.grey);

          return Register(
              ogcFid: register['ogcFid'],
              tipo: register['tipo'],
              point: circle);
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      printOnDebug('Error al obtener registros: $error');
      rethrow;
    }
  }

  Future<Register?> fetchRegisterById(String token, int sectionId) async {
    try {
      final url = Uri.parse('$baseUrl/$sourcePath/$sectionId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Register(
          ogcFid: jsonResponse['ogcFid'],
          datoObra: jsonResponse['datoObra'],
          gid: jsonResponse['gid'],
          elemRed: jsonResponse['elemRed'],
          lonC: jsonResponse['lonc'],
          latC: jsonResponse['latc'],
          cota: jsonResponse['cota'],
          inspeccion: jsonResponse['inspeccion'],
          tipo: jsonResponse['tipo'],
          descripcion: jsonResponse['descripcio'],
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
