import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants/theme_constants.dart';
import '../models/lot_data.dart';
import '../utils/common_utils.dart';

class LotService {
  final String baseUrl;
  static const sourcePath = 'parcelas';

  LotService({String? baseUrl})
      : baseUrl =
            baseUrl ?? dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Lot>?> fetchLotsByRadius(
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
        return jsonResponse.map<Lot>((lot) {
          Map<String, dynamic> geoJson = lot['geoJSON'];
          List<dynamic> multiLineCoordinatesWrapper = geoJson['coordinates'];
          int ogcFid = lot['ogcFid'];
          List<LatLng> latLngList = [];

          List<dynamic> multiLineCoordinates =
              multiLineCoordinatesWrapper.first;
          for (var coordinatesList in multiLineCoordinates) {
            for (var coord in coordinatesList) {
              double latitude = coord[1];
              double longitude = coord[0];
              latLngList.add(LatLng(latitude, longitude));
            }
          }

          Polyline polyline = Polyline(
              polylineId: PolylineId(ogcFid.toString()),
              points: latLngList,
              color: lotDefaultColor,
              width: 4,
              consumeTapEvents: true);

          return Lot(ogcFid: ogcFid, polyline: polyline);
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      printOnDebug('Error al obtener captaciones: $error');
      rethrow;
    }
  }

  Future<Lot?> fetchLotById(String token, int LotId) async {
    try {
      final url = Uri.parse('$baseUrl/$sourcePath/$LotId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Lot(
            ogcFid: jsonResponse['ogcFid'],
            gid: jsonResponse['gid'],
            padron: jsonResponse['padron'],
            areatot: jsonResponse['areatot'],
            areacat: jsonResponse['areacat'],
            ph: jsonResponse['ph'],
            imponible: jsonResponse['imponible'],
            carpetaPh: jsonResponse['carpetaPh'],
            categoria: jsonResponse['categoria'],
            subCategoria: jsonResponse['subCategoria'],
            areaDifer: jsonResponse['areaDifer'],
            cortado_rn: jsonResponse['cortado_rn'],
            rn_area_di: jsonResponse['rn_area_di'],
            rgs: jsonResponse['rgs'],
            retiro: jsonResponse['retiro'],
            galibo: jsonResponse['galibo'],
            altura: jsonResponse['altura'],
            fos: jsonResponse['fos'],
            usopre: jsonResponse['usopre'],
            planesp: jsonResponse['planesp'],
            planparcia: jsonResponse['planparcia'],
            promo: jsonResponse['promo'],
            fis: jsonResponse['fis'],
            nom_trans: jsonResponse['nom_trans'],
            tipo_trans: jsonResponse['tipo_trans'],
            estado_tra: jsonResponse['estado_tra']);
      } else {
        return null;
      }
    } catch (error) {
      printOnDebug('Error al obtener parcelas: $error');
      rethrow;
    }
  }
}
