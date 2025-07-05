import 'package:shared_preferences/shared_preferences.dart';
import '../consts.dart';

/// Service for clearing SharedPreferences data during logout, account deletion, and deactivation.
/// 
/// This service provides methods to clear different types of stored data:
/// - User authentication data (user_id, username, firebase_uid, access tokens)
/// - Device information (device_id, device_fingerprint)
/// - Notification preferences (fcm_token, notification_enabled)
/// - Profile cache (profile data and timestamps)
/// - Chat cache (all chat messages)
/// - App preferences (language, theme - optional)
/// 
/// Usage:
/// ```dart
/// final clearService = SharedPreferencesClearService();
/// 
/// // Clear all user data (recommended for logout/delete/deactivate)
/// await clearService.clearAllUserData();
/// 
/// // Clear only user-specific data (preserves app settings)
/// await clearService.clearUserSpecificData();
/// 
/// // Clear everything including app settings (use with caution)
/// await clearService.clearEverything();
/// ```
class SharedPreferencesClearService {
  static final SharedPreferencesClearService _instance = SharedPreferencesClearService._internal();
  factory SharedPreferencesClearService() => _instance;
  SharedPreferencesClearService._internal();

  /// Clear all user-related shared preferences data
  /// This includes authentication data, user preferences, cached data, etc.
  /// 
  /// This method is called during:
  /// - User logout
  /// - Account deactivation
  /// - Account deletion
  /// 
  /// It preserves app-wide settings like language and theme preferences.
  Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print("🧹 Starting to clear all shared preferences...");
      
      // Clear user authentication data
      await _clearUserAuthData(prefs);
      
      // Clear device information
      await _clearDeviceData(prefs);
      
      // Clear notification preferences
      await _clearNotificationData(prefs);
      
      // Clear profile cache
      await _clearProfileCache(prefs);
      
      // Clear chat cache
      await _clearChatCache(prefs);
      
      // Clear other app preferences
      await _clearAppPreferences(prefs);
      
      print("✅ All shared preferences cleared successfully");
    } catch (e) {
      print("❌ Error clearing shared preferences: $e");
      rethrow;
    }
  }

  /// Clear user authentication data
  Future<void> _clearUserAuthData(SharedPreferences prefs) async {
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('firebase_uid');
    await prefs.remove(AppConstants.accessToken);
    print("🔐 User authentication data cleared");
  }

  /// Clear device information
  Future<void> _clearDeviceData(SharedPreferences prefs) async {
    await prefs.remove('device_id');
    await prefs.remove('device_fingerprint');
    print("📱 Device information cleared");
  }

  /// Clear notification preferences
  Future<void> _clearNotificationData(SharedPreferences prefs) async {
    await prefs.remove('fcm_token');
    await prefs.remove(AppConstants.fcmtoken);
    await prefs.remove('notification_enabled');
    print("🔔 Notification preferences cleared");
  }

  /// Clear profile cache
  Future<void> _clearProfileCache(SharedPreferences prefs) async {
    await prefs.remove('profile_data_cache');
    await prefs.remove('profile_data_cache_timestamp');
    await prefs.remove('profile_pic_url_cache');
    await prefs.remove('profile_pic_url_cache_timestamp');
    print("👤 Profile cache cleared");
  }

  /// Clear chat cache (all chat messages)
  Future<void> _clearChatCache(SharedPreferences prefs) async {
    final keys = prefs.getKeys();
    final chatKeys = keys.where((key) => key.startsWith('chat_messages_')).toList();
    for (String key in chatKeys) {
      await prefs.remove(key);
    }
    print("💬 Chat cache cleared (${chatKeys.length} chat sessions)");
  }

  /// Clear other app preferences
  Future<void> _clearAppPreferences(SharedPreferences prefs) async {
    // Note: We don't clear language and theme preferences as these are app-wide settings
    // that should persist across user sessions
    print("⚙️ App preferences preserved (language, theme)");
  }

  /// Clear only user-specific data (preserves app settings like language and theme)
  /// 
  /// Use this method when you want to clear user data but keep app-wide settings
  /// that should persist across different user sessions.
  Future<void> clearUserSpecificData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print("🧹 Starting to clear user-specific data...");
      
      await _clearUserAuthData(prefs);
      await _clearDeviceData(prefs);
      await _clearNotificationData(prefs);
      await _clearProfileCache(prefs);
      await _clearChatCache(prefs);
      
      print("✅ User-specific data cleared successfully");
    } catch (e) {
      print("❌ Error clearing user-specific data: $e");
      rethrow;
    }
  }

  /// Clear everything including app settings (use with caution)
  /// 
  /// This method clears ALL stored data including app-wide settings like
  /// language and theme preferences. Use this only when you want to reset
  /// the entire app to its initial state.
  Future<void> clearEverything() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print("🧹 Starting to clear ALL shared preferences...");
      
      await clearAllUserData();
      
      // Also clear app-wide settings
      await prefs.remove('language');
      await prefs.remove('isDarkMode');
      
      print("✅ ALL shared preferences cleared (including app settings)");
    } catch (e) {
      print("❌ Error clearing all preferences: $e");
      rethrow;
    }
  }

  /// Get a list of all stored keys (for debugging)
  /// 
  /// This method is useful for debugging to see what data is currently stored
  /// in SharedPreferences.
  Future<List<String>> getAllStoredKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().toList();
  }

  /// Check if user data exists
  /// 
  /// Returns true if any user authentication data is found in SharedPreferences.
  Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null || 
           prefs.getString('username') != null ||
           prefs.getString('firebase_uid') != null;
  }

  /// Clear only authentication data
  /// 
  /// Use this when you want to clear only user authentication data
  /// but keep other cached data like chat messages or profile cache.
  Future<void> clearAuthDataOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearUserAuthData(prefs);
      print("✅ Authentication data cleared only");
    } catch (e) {
      print("❌ Error clearing authentication data: $e");
      rethrow;
    }
  }

  /// Clear only chat data
  /// 
  /// Use this when you want to clear only chat messages
  /// but keep other user data.
  Future<void> clearChatDataOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearChatCache(prefs);
      print("✅ Chat data cleared only");
    } catch (e) {
      print("❌ Error clearing chat data: $e");
      rethrow;
    }
  }

  /// Clear only profile cache
  /// 
  /// Use this when you want to clear only profile cache
  /// but keep other user data.
  Future<void> clearProfileCacheOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearProfileCache(prefs);
      print("✅ Profile cache cleared only");
    } catch (e) {
      print("❌ Error clearing profile cache: $e");
      rethrow;
    }
  }
} 