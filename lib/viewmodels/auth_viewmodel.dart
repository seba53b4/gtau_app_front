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

      final authDataResponse = await _authService.fetchAuth(username, password);

      if (authDataResponse.authData != null) {
        return authDataResponse;
      }
      _error = true;
      return null;
    } catch (error) {
      _error = true;
      throw Exception('Error al obtener los datos de autenticación');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult?> refreshAuth(String refreshToken) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final authDataResponse = await _authService.refreshAuthData(refreshToken);

      if (authDataResponse.authData != null) {
        return authDataResponse;
      }
      return null;
    } catch (error) {
      _error = true;
      throw Exception('Error al obtener los datos de refresh auth');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
