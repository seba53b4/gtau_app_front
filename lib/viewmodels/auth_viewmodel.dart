import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/services/auth_service.dart';

import '../models/user_info.dart';
import '../utils/common_utils.dart';

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
      return authDataResponse;
    } catch (error) {
      _error = true;
      throw Exception('Error al obtener los datos de autenticación');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recoverPassword(String email, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final response = await _authService.recoverPassword(email, body);

      if (response) {
        notifyListeners();
        return true;
      } else {
        _error = true;
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      _error = true;
      throw Exception('Error al obtener los datos de autenticación');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserInfo?> getUserRole(String token) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final userInfoResponse = await _authService.getUserRole(token);

      if (userInfoResponse != null) {
        return userInfoResponse;
      }
      _error = true;
      return null;
    } catch (error) {
      _error = true;
      throw Exception('Error getUserRole');
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
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
