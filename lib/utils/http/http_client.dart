import 'package:http/http.dart' as http;
import 'dart:convert';

class FHttpHelper {
  static const String _baseUrl = 'https://cash-compass-ph0d.onrender.com';

  // Helper method to make a GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  // Helper method to make a POST request
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // Handle the HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final responses = {
        "jsonResponse": response,
        "responseBody": response.body
      };
      return responses;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

}
