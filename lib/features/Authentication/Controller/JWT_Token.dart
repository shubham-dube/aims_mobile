import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }
}