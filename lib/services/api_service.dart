import 'dart:convert';
import 'dart:io';  // Import the dart:io package

import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';  // For device fingerprint
import 'package:gemini_chat_app_tutorial/consts.dart'; // To access AppConstants

class ApiService {
  // You no longer need to pass the base URL. It's now fetched from AppConstants.
  
  // Function to fetch device ID and fingerprint and send it to the API
  Future<void> continueAsGuest() async {
    try {
      // Fetch the device ID from AppConstants
      String deviceId = AppConstants.deviceId;
      
      // Get the device fingerprint
      String deviceFingerprint = await _getDeviceFingerprint();

      if (deviceId.isEmpty) {
        throw 'Device ID is empty';
      }

      // API endpoint to continue as guest
      final url = Uri.parse('${AppConstants.baseUrl}/guestUser');  // Using baseUrl from AppConstants

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'deviceFingerprint': deviceFingerprint,
        }),
      );

      // Modify this part in continueAsGuest()
if (response.statusCode == 201) {  // Note: your backend returns 201 for creation
  print('Guest user API success: ${response.body}');
  return json.decode(response.body); // Return the response
} else {
  print('API error: Status ${response.statusCode}, Body: ${response.body}');
  throw 'Failed to continue as guest: ${response.statusCode}';
}
  }




  // Function to get the device fingerprint
  Future<String> _getDeviceFingerprint() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fingerprint = '';

    try {
      // Get platform-specific device fingerprint
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


   // Function to submit only the name
  Future<void> submitUserData(String name) async {
    // final url = Uri.parse('$baseUrl/userDetails');  // Example endpoint
        final url = Uri.parse('${AppConstants.baseUrl}/userDetails'); // Use AppConstants.baseUrl


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,  // Send only the name
        }),
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

  Future<void> sendInterest(String interest) async {
    // final url = Uri.parse('$baseUrl/interest');  // API endpoint for interest
        final url = Uri.parse('${AppConstants.baseUrl}/interest'); // Use AppConstants.baseUrl


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
