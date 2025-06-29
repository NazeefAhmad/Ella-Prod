import 'package:shared_preferences/shared_preferences.dart';
import 'package:hoocup/consts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'dart:convert' show utf8;

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

  // Validate JWT token format (basic structure check)
  bool isValidJwtFormat(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid JWT format: Token should have 3 parts separated by dots');
        return false;
      }
      return true;
    } catch (e) {
      print('Error validating JWT format: $e');
      return false;
    }
  }

  // Decode JWT token and get payload
  Map<String, dynamic>? decodeToken(String token) {
    try {
      if (!isValidJwtFormat(token)) {
        return null;
      }
      
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  // Check if JWT token is expired
  bool isTokenExpired(String token) {
    try {
      if (!isValidJwtFormat(token)) {
        return true;
      }
      
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error checking JWT token expiration: $e');
      return true;
    }
  }

  // Get token expiration date
  DateTime? getTokenExpirationDate(String token) {
    try {
      if (!isValidJwtFormat(token)) {
        return null;
      }
      
      final decodedToken = JwtDecoder.decode(token);
      final exp = decodedToken['exp'];
      
      if (exp != null) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      print('Error getting JWT token expiration date: $e');
      return null;
    }
  }

  // Get token issued date
  DateTime? getTokenIssuedDate(String token) {
    try {
      if (!isValidJwtFormat(token)) {
        return null;
      }
      
      final decodedToken = JwtDecoder.decode(token);
      final iat = decodedToken['iat'];
      
      if (iat != null) {
        return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
      }
      return null;
    } catch (e) {
      print('Error getting JWT token issued date: $e');
      return null;
    }
  }

  // Get user ID from token
  String? getUserIdFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      if (decodedToken != null) {
        return decodedToken['user_id']?.toString() ?? 
               decodedToken['sub']?.toString() ?? 
               decodedToken['uid']?.toString();
      }
      return null;
    } catch (e) {
      print('Error getting user ID from JWT token: $e');
      return null;
    }
  }

  // Validate token and get detailed info
  Map<String, dynamic> validateToken(String token) {
    final Map<String, dynamic> result = {
      'isValid': false,
      'isExpired': true,
      'expirationDate': null,
      'issuedDate': null,
      'userId': null,
      'payload': null,
      'error': null,
    };

    try {
      if (!isValidJwtFormat(token)) {
        result['error'] = 'Invalid JWT format';
        return result;
      }

      final decodedToken = decodeToken(token);
      if (decodedToken == null) {
        result['error'] = 'Failed to decode JWT token';
        return result;
      }

      final isExpired = isTokenExpired(token);
      final expirationDate = getTokenExpirationDate(token);
      final issuedDate = getTokenIssuedDate(token);
      final userId = getUserIdFromToken(token);

      result['isValid'] = true;
      result['isExpired'] = isExpired;
      result['expirationDate'] = expirationDate?.toIso8601String();
      result['issuedDate'] = issuedDate?.toIso8601String();
      result['userId'] = userId;
      result['payload'] = decodedToken;

    } catch (e) {
      result['error'] = 'Token validation error: $e';
    }

    return result;
  }

  // Get current token validation status
  Future<Map<String, dynamic>> getCurrentTokenStatus() async {
    final token = await getToken();
    if (token == null) {
      return {
        'hasToken': false,
        'isValid': false,
        'error': 'No token found',
      };
    }

    final validation = validateToken(token);
    return {
      'hasToken': true,
      ...validation,
    };
  }

  // Log token information for debugging
  Future<void> logTokenInfo() async {
    final token = await getToken();
    if (token == null) {
      print('🔍 JWT Token Info: No token found');
      return;
    }

    print('🔍 JWT Token Info:');
    print('Token (first 20 chars): ${token.substring(0, 20)}...');
    print('Token (last 20 chars): ...${token.substring(token.length - 20)}');
    print('Token length: ${token.length}');
    print('Token contains dots: ${token.contains('.')}');
    print('Number of dots: ${token.split('.').length - 1}');
    
    // Show the actual token structure
    final parts = token.split('.');
    print('Token parts count: ${parts.length}');
    for (int i = 0; i < parts.length; i++) {
      print('Part $i length: ${parts[i].length}');
      if (parts[i].length > 50) {
        print('Part $i (first 50 chars): ${parts[i].substring(0, 50)}...');
      } else {
        print('Part $i: ${parts[i]}');
      }
    }
    
    final validation = validateToken(token);
    print('Is Valid: ${validation['isValid']}');
    print('Is Expired: ${validation['isExpired']}');
    print('Expiration Date: ${validation['expirationDate']}');
    print('Issued Date: ${validation['issuedDate']}');
    print('User ID: ${validation['userId']}');
    
    if (validation['error'] != null) {
      print('Error: ${validation['error']}');
    }
    
    if (validation['payload'] != null) {
      print('Payload Keys: ${(validation['payload'] as Map<String, dynamic>).keys.toList()}');
    }
  }

  // Inspect raw token content
  Future<void> inspectRawToken() async {
    final token = await getToken();
    if (token == null) {
      print('🔍 Raw Token Inspection: No token found');
      return;
    }

    print('🔍 Raw Token Inspection:');
    print('Full token: $token');
    print('Token type: ${token.runtimeType}');
    print('Token length: ${token.length}');
    print('Contains spaces: ${token.contains(' ')}');
    print('Contains newlines: ${token.contains('\n')}');
    print('Contains quotes: ${token.contains('"')}');
    print('Contains brackets: ${token.contains('{') || token.contains('}')}');
    
    // Check if it looks like JSON
    if (token.trim().startsWith('{') && token.trim().endsWith('}')) {
      print('⚠️ Token appears to be JSON, not JWT');
      try {
        final jsonData = json.decode(token);
        print('JSON keys: ${jsonData.keys.toList()}');
        if (jsonData.containsKey('access_token')) {
          print('✅ Found access_token in JSON response');
          final actualToken = jsonData['access_token'];
          print('Actual JWT token: ${actualToken.toString().substring(0, 20)}...');
        }
      } catch (e) {
        print('Error parsing as JSON: $e');
      }
    }
    
    // Check if it's base64 encoded
    try {
      final decoded = utf8.decode(base64Url.decode(token.split('.')[0] + '=='));
      print('Header (decoded): $decoded');
    } catch (e) {
      print('Not base64 encoded or invalid format');
    }
  }
} 