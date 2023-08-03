import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  final storage = const FlutterSecureStorage();

// Log In
  Future<String> loginUser(String studentId, String password) async {
    final response = await http.post(Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'studentId': studentId, 'password': password}));

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'];

      // Save the token securely
      await storage.write(key: 'token', value: token);

      return 'Login successful';
    } else {
      throw Exception('Failed to login');
    }
  }

// Sign Up
  Future<String> signUpUser(
      String firstName,
      String lastName,
      String studentId,
      String email,
      String major,
      String college,
      String grade,
      List<String> interests,
      List<String> clubs,
      List<String> followEvents,
      String password) async {
    final response = await http.post(Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'studentId': studentId,
          'email': email,
          'major': major,
          'college': college,
          'grade': grade,
          'interests': interests,
          'clubs': clubs,
          'follow_events': followEvents,
          'password': password,
        }));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('json: $jsonResponse');
      final token = json.decode(response.body)['token'];
      print('Token from response: $token');
      await storage.write(key: 'token', value: token);
      print('Token saved after signup: $token');
      //return token;
      return response.body;
      // final token = json.decode(response.body)['token'];
      // print('Token from response: $token');
      // await storage.write(key: 'token', value: token);
      // print('Token saved after signup: $token');
      // return response.body;
    } else {
      throw Exception('Failed to sign up');
    }
  }

  Future<String> getUserAuthToken() async {
    final token = await storage.read(key: 'token');

    if (token is String) {
      print('token is: $token');
      return token;
    } else {
      // Handle the scenario where the token is not available
      throw Exception('Token not found');
    }
  }

  Future<bool> isAuthenticated() async {
    // Retrieve the token
    final token = await storage.read(key: 'token');

    // Check if the token is available and not empty
    return token != null && token.isNotEmpty;
  }

  // Log Out
  Future<void> logoutUser() async {
    // Remove the token from the secure storage
    await storage.delete(key: 'token');
  }
}
