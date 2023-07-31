import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/auth_service.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:provider/provider.dart';
import '../models/auth_data.dart';
import '../providers/user_provider.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<AuthData?> fetchAuth(String username, String password) async {
    try {
      final authData = await _authService.fetchAuth(username, password);

      if (authData != null) {
        print('Usuario y contraseña válidos');
        notifyListeners();
        return authData;
      } else {
        print('Contraseña incorrecta');
        return null;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos de autenticación');
    }
  }



}
