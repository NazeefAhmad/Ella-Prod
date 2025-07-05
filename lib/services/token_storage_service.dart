import 'package:hoocup/consts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _tokenExpiryKey, value: expiryTime.toIso8601String());
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<bool> isAccessTokenExpired() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString == null) {
      print('Token expiry time not found');
      return true;
    }

    final expiryTime = DateTime.parse(expiryString);
    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);
    print('Token expires in: ${timeUntilExpiry.inMinutes} minutes');
    
    // Consider token expired if it's within 10 minutes of expiry
    final isExpired = now.isAfter(expiryTime.subtract(const Duration(minutes: 10)));
    if (isExpired) {
      print('Token is expired or will expire soon');
    }
    return isExpired;
  }

  // Add method to check if token needs refresh
  Future<bool> needsRefresh() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString == null) {
      print('Token expiry time not found in needsRefresh check');
      return true;
    }

    final expiryTime = DateTime.parse(expiryString);
    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);
    print('Token refresh check : Time until expiry: ${timeUntilExpiry.inMinutes} minutes');
    
    // Start refresh process when token is within 15 minutes of expiry
    final needsRefresh = now.isAfter(expiryTime.subtract(const Duration(minutes: 15)));
    if (needsRefresh) {
      print('Token needs refresh - within 15 minutes of expiry');
    }
    return needsRefresh;
  }

  // Add method to get token expiry time
  Future<DateTime?> getTokenExpiryTime() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString == null) return null;
    return DateTime.parse(expiryString);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final isExpired = await isAccessTokenExpired();
    return accessToken != null && refreshToken != null && !isExpired;
  }
} 