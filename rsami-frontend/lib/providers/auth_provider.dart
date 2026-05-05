import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _role;

  bool get isAuthenticated => _token != null;
  bool get isAdmin => _role == 'ADMIN';
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      _userId = data['user']['id'];
      _userName = data['user']['name'];
      _role = data['user']['role'];
      notifyListeners();
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Login failed');
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}
