import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../consts.dart';

/// Service for handling app version checking and updates
/// 
/// This service provides functionality to:
/// - Check for app updates against a remote API
/// - Handle both force and optional updates
/// - Launch app store for updates
/// - Compare version strings
/// 
/// Expected API Response Format:
/// {
///   "version": "1.2.3",
///   "force_update": false,
///   "url": "https://example.com/download/app",
///   "minimum_versions": {
///     "android": "1.2.0",
///     "ios": "1.2.0"
///   }
/// }
class VersionService {
  final _baseUrl = AppConstants.baseUrl.trim();

  /// Checks for app updates and returns detailed version information
  /// 
  /// Returns a Map containing:
  /// - needs_update: bool - Whether an update is required
  /// - current_version: String - Current app version
  /// - latest_version: String - Latest available version
  /// - minimum_version: String - Minimum required version for the platform
  /// - platform: String - Current platform (android/ios)
  /// - update_available: bool - Whether an update is available
  /// - force_update: bool - Whether the update is mandatory
  /// - update_url: String? - URL to download the update
  /// - update_message: String? - Custom message for the update dialog
  /// - error: String? - Error message if check failed
  Future<Map<String, dynamic>> checkForUpdate() async {
    print('🔄 Starting version check...');
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String platform = Platform.isAndroid ? 'android' : 'ios';
      print('📱 Current app version: $currentVersion');
      print('📱 Platform: $platform');
      
      // Get the latest version from your API
      final url = '$_baseUrl/app/version';
      print('🌐 Checking for updates at: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📄 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Parsed response data: $data');
        
        // Extract version information
        final String? latestVersion = data['version'] ?? data['api_version'] ?? data['app_version'];
        final bool forceUpdate = data['force_update'] ?? data['force_update_required'] ?? false;
        final Map<String, String>? minVersions = data['minimum_versions'] != null 
            ? Map<String, String>.from(data['minimum_versions'])
            : null;
        final String? updateUrl = data['url'] ?? data['update_url'] ?? data['download_url'];
        
        print('🔍 Latest version from API: $latestVersion');
        print('⚠️ Force update required: $forceUpdate');
        print('📱 Minimum versions: $minVersions');
        print('🔗 Update URL: $updateUrl');

        // Check if latestVersion is not null before comparing
        if (latestVersion != null) {
          print('✅ Version field is valid, comparing versions...');
          // Compare versions
          final comparison = _compareVersions(currentVersion, latestVersion);
          print('⚖️ Version comparison result: $comparison (current vs latest)');
          
          final bool needsUpdate = comparison < 0;
          
          if (needsUpdate) {
            print('🆕 Update available! Current: $currentVersion, Latest: $latestVersion');
          } else {
            print('✅ App is up to date. Current: $currentVersion, Latest: $latestVersion');
          }

          return {
            "needs_update": needsUpdate,
            "current_version": currentVersion,
            "latest_version": latestVersion,
            "minimum_version": minVersions?[platform] ?? latestVersion,
            "platform": platform,
            "update_available": needsUpdate,
            "force_update": forceUpdate,
            "update_url": updateUrl,
            "update_message": needsUpdate 
                ? (forceUpdate 
                    ? "A critical update is required. Please update your app to continue." 
                    : "A new version is available. Please update your app for the best experience.")
                : null
          };
        } else {
          print('❌ Version field is null or missing in API response');
          print('🔍 Available fields in response: ${data.keys.toList()}');
        }
      } else {
        print('❌ API request failed with status: ${response.statusCode}');
      }
      
      // Return default response when no update is needed or error occurs
      return {
        "needs_update": false,
        "current_version": currentVersion,
        "latest_version": currentVersion,
        "minimum_version": currentVersion,
        "platform": platform,
        "update_available": false,
        "force_update": false,
        "update_url": null,
        "update_message": null
      };
    } catch (e) {
      print('💥 Error checking for updates: $e');
      print('🔍 Error type: ${e.runtimeType}');
      
      // Return error response
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String platform = Platform.isAndroid ? 'android' : 'ios';
      
      return {
        "needs_update": false,
        "current_version": currentVersion,
        "latest_version": currentVersion,
        "minimum_version": currentVersion,
        "platform": platform,
        "update_available": false,
        "force_update": false,
        "update_url": null,
        "update_message": null,
        "error": e.toString()
      };
    }
  }

  /// Legacy method for backward compatibility
  /// 
  /// Returns only a boolean indicating if an update is needed.
  /// Use checkForUpdate() for detailed version information.
  Future<bool> checkForUpdateLegacy() async {
    final result = await checkForUpdate();
    return result["needs_update"] ?? false;
  }

  /// Launches the appropriate app store for the current platform
  /// 
  /// Opens the Play Store on Android or App Store on iOS
  Future<void> launchStore() async {
    print('🛒 Launching app store...');
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/apps/details?id=com.Hoocup.hoocup');
      print('🤖 Android store URL: $url');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/app/hoocup/id1234567890'); // Replace with your App Store ID
      print('🍎 iOS store URL: $url');
    } else {
      print('❌ Unsupported platform for store launch');
      return;
    }

    print('🚀 Attempting to launch URL: $url');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('💥 Failed to launch store URL');
      throw Exception('Could not launch store URL');
    }
    print('✅ Store URL launched successfully');
  }

  /// Launches a custom update URL
  /// 
  /// Opens the provided URL in external browser
  Future<void> launchUpdateUrl(String url) async {
    print('🔗 Launching custom update URL: $url');
    final Uri uri = Uri.parse(url);
    
    print('🚀 Attempting to launch URL: $uri');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('💥 Failed to launch custom update URL');
      throw Exception('Could not launch custom update URL');
    }
    print('✅ Custom update URL launched successfully');
  }

  /// Compares two version strings and returns the comparison result
  /// 
  /// Returns:
  /// - -1 if version1 < version2 (version1 is older)
  /// - 0 if version1 == version2 (versions are equal)
  /// - 1 if version1 > version2 (version1 is newer)
  /// 
  /// Example: "1.2.3" vs "1.2.4" returns -1
  int _compareVersions(String version1, String version2) {
    print('🔍 Comparing versions: "$version1" vs "$version2"');
    
    List<int> v1 = version1.split('.').map(int.parse).toList();
    List<int> v2 = version2.split('.').map(int.parse).toList();
    
    print('📊 Parsed version 1: $v1');
    print('📊 Parsed version 2: $v2');

    for (int i = 0; i < v1.length && i < v2.length; i++) {
      print('🔢 Comparing segment $i: ${v1[i]} vs ${v2[i]}');
      if (v1[i] < v2[i]) {
        print('📉 Version 1 is older at segment $i');
        return -1;
      }
      if (v1[i] > v2[i]) {
        print('📈 Version 1 is newer at segment $i');
        return 1;
      }
    }

    if (v1.length < v2.length) {
      print('📉 Version 1 has fewer segments, considered older');
      return -1;
    }
    if (v1.length > v2.length) {
      print('📈 Version 1 has more segments, considered newer');
      return 1;
    }
    print('✅ Versions are identical');
    return 0;
  }
} 