import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../consts.dart';

class VersionService {
  final _baseUrl = AppConstants.baseUrl.trim();

  Future<bool> checkForUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      
      // Get the latest version from your API
      final response = await http.get(
        Uri.parse('$_baseUrl/app/version'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestVersion = data['version'];
        final bool forceUpdate = data['force_update'] ?? false;

        // Compare versions
        if (_compareVersions(currentVersion, latestVersion) < 0) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  Future<void> launchStore() async {
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/apps/details?id=com.Hoocup.hoocup');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/app/hoocup/id1234567890'); // Replace with your App Store ID
    } else {
      return;
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch store URL');
    }
  }

  // Helper method to compare version strings
  int _compareVersions(String version1, String version2) {
    List<int> v1 = version1.split('.').map(int.parse).toList();
    List<int> v2 = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1.length && i < v2.length; i++) {
      if (v1[i] < v2[i]) return -1;
      if (v1[i] > v2[i]) return 1;
    }

    if (v1.length < v2.length) return -1;
    if (v1.length > v2.length) return 1;
    return 0;
  }
} 