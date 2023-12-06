import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  Future<AuthResult?> fetchAuth(String username, String password) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final authData = await _authService.fetchAuth(username, password);

      if (authData != null) {
        print('Usuario y contraseña válidos');
        return authData;
      }
      _error = true;
      print('Contraseña incorrecta');
      return null;
    } catch (error) {
      _error = true;
      print('Error al obtener los datos de autenticación: $error');
      throw Exception('Error al obtener los datos de autenticación');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
