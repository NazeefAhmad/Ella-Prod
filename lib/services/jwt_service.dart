import 'package:shared_preferences/shared_preferences.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessToken);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
} 