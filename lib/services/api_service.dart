import 'dart:convert';
import 'dart:io';  
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';  
import 'package:gemini_chat_app_tutorial/consts.dart';  

class ApiService {
  // Function to get the device fingerprint
  Future<String> _getDeviceFingerprint() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fingerprint = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        fingerprint = androidInfo.fingerprint ?? 'Unknown Fingerprint';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        fingerprint = iosInfo.identifierForVendor ?? 'Unknown Fingerprint';
      }
    } catch (e) {
      print('Error fetching device fingerprint: $e');
    }

    return fingerprint;
  }

  // Function to fetch device ID and fingerprint and send it to the API
  Future<void> continueAsGuest() async {
    try {
      String deviceId = AppConstants.deviceId;
      String deviceFingerprint = await _getDeviceFingerprint();

      if (deviceId.isEmpty) {
        throw 'Device ID is empty';
      }

      final url = Uri.parse('${AppConstants.baseUrl}/guestUser');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'deviceFingerprint': deviceFingerprint,
        }),
      );

      if (response.statusCode == 201) { 
        print('Guest user API success: ${response.body}');
      } else {
        print('API error: Status ${response.statusCode}, Body: ${response.body}');
        throw 'Failed to continue as guest: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in continueAsGuest: $e');
    }
  }

  // Function to submit user name
  Future<void> submitUserData(String name) async {
    final url = Uri.parse('${AppConstants.baseUrl}/userDetails'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        print('User data submitted successfully: ${response.body}');
      } else {
        print('Failed to submit user data: ${response.body}');
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }

  // Function to send user interest
  Future<void> sendInterest(String interest) async {
    final url = Uri.parse('${AppConstants.baseUrl}/interest'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'interest': interest}),
      );

      if (response.statusCode == 200) {
        print('Interest sent successfully: ${response.body}');
      } else {
        print('Failed to send interest: ${response.body}');
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }
}
