import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hoocup/services/token_storage_service.dart';
import 'package:hoocup/services/api_service.dart';
import 'package:hoocup/services/shared_preferences_clear_service.dart';
import 'package:get/get.dart';
import 'package:hoocup/consts.dart';
import 'package:hoocup/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:hoocup/firebase_options.dart';

class AuthService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final ApiService _apiService = ApiService();
  final ProfileService _profileService = ProfileService();
  final SharedPreferencesClearService _prefsClearService = SharedPreferencesClearService();
  Timer? _tokenRefreshTimer;

  // Start background token refresh
  void startTokenRefresh() {
    // Cancel any existing timer
    _tokenRefreshTimer?.cancel();
    
    // Check token status every minute
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        if (await _tokenStorage.needsRefresh()) {
          print('Token needs refresh, attempting to refresh...');
          await _apiService.refreshAccessToken();
        }
      } catch (e) {
        print('Error in background token refresh: $e');
      }
    });
  }

  // Stop background token refresh
  void stopTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  @override
  void dispose() {
    stopTokenRefresh();
  }

  // Validate JWT token format
  bool _isValidJwtFormat(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      print('Invalid JWT format: Token should have 3 parts separated by dots');
      return false;
    }
    return true;
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In process...");

      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        print("❌ Firebase not initialized. Initializing now...");
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("✅ Firebase initialized for Google Sign-In");
      }

      // Initialize GoogleSignIn
      await GoogleSignIn.instance.initialize();

      print("🔐 Attempting Google Sign-In...");
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );

      print("✅ Google user authenticated: ${googleUser.email}");

      final idToken = googleUser.authentication.idToken;
      final clientAuth = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
      final googleAccessToken = clientAuth?.accessToken;

      print("✅ Google authentication obtained: "
          "AccessToken: ${googleAccessToken != null ? 'Present' : 'Missing'}, "
          "IDToken: ${idToken != null ? 'Present' : 'Missing'}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAccessToken,
        idToken: idToken,
      );

      print("🔥 Signing in with Firebase credentials...");

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Get the Firebase ID token instead of using the Google ID token
      String? firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        throw 'Failed to get Firebase ID token';
      }

      print("✅ Firebase ID token obtained: ${firebaseIdToken.substring(0, 20)}...");
      
      // Get JWT tokens from your backend using the Firebase ID token
      final response = await _apiService.getGoogleAuthToken(
        firebaseIdToken,
        userCredential.user!.uid,
        userCredential.user!.email!,
      );

      if (response == null) {
        throw 'Failed to get response from server';
      }

      // Validate JWT tokens before storing
      final accessToken = response['access_token'] as String?;
      if (accessToken == null) {
        throw 'Access token not found in response';
      }

      // Set user ID and username in AppConstants
      if (response['user'] != null) {
        final userData = response['user'] as Map<String, dynamic>;
        AppConstants.userId = userData['_id'] as String? ?? '';
        
        // Extract username from email (everything before @)
        final email = userData['email'] as String? ?? '';
        final defaultUsername = email.isNotEmpty ? email.split('@')[0] : 'User';
        AppConstants.userName = userData['username'] as String? ?? defaultUsername;
        
        // Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', AppConstants.userId);
        await prefs.setString('username', AppConstants.userName);
        
        print("✅ Set user ID: ${AppConstants.userId}");
        print("✅ Set username: ${AppConstants.userName}");
      }

      print("🎉 Sign-in successful. User: ${userCredential.user?.email}");
      print("✅ Access Token: ${accessToken.substring(0, 20)}..."); // Log first 20 chars for debugging

      // Start token refresh after successful sign in
      startTokenRefresh();
      return userCredential.user;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  // Guest Sign-In
  Future<bool> signInAsGuest() async {
    try {
      final response = await _apiService.continueAsGuest();
      
      // Validate JWT tokens before storing
      final accessToken = response['access_token'] as String?;
      final refreshToken = response['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw 'Invalid token format received from server';
      }

      if (!_isValidJwtFormat(accessToken)) {
        throw 'Invalid access token format received from server';
      }
      if (!_isValidJwtFormat(refreshToken)) {
        throw 'Invalid refresh token format received from server';
      }

      // Set user ID and username in AppConstants
      if (response['user'] != null) {
        final userData = response['user'] as Map<String, dynamic>;
        AppConstants.userId = userData['_id'] as String? ?? '';
        AppConstants.userName = userData['username'] as String? ?? 'Guest';
        
        // Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', AppConstants.userId);
        await prefs.setString('username', AppConstants.userName);
        
        print("Set guest user ID: ${AppConstants.userId}");
        print("Set guest username: ${AppConstants.userName}");
      }

      print("Guest sign-in successful");
      print("Access Token: ${accessToken.substring(0, 20)}..."); // Log first 20 chars for debugging
      print("Refresh Token: ${refreshToken.substring(0, 20)}..."); // Log first 20 chars for debugging

      // Start token refresh after successful guest sign in
      startTokenRefresh();

      return true;
    } catch (e) {
      print("Guest Sign-In Error: $e");
      return false;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _profileService.getUserProfile();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print("Starting sign out process...");
      
      // Stop token refresh
      stopTokenRefresh();
      
      // Get device ID
      String deviceId = AppConstants.deviceId;
      
      // Logout from backend
      try {
        await _apiService.logout(deviceId);
        print("Backend logout successful");
      } catch (e) {
        print("Backend logout failed: $e");
        // Continue with local logout even if backend logout fails
      }

      // Sign out from Google
      try {
        print("Signing out from Google...");
        await GoogleSignIn.instance.signOut();
        print("Google Sign-Out successful.");
      } catch (e) {
        print("Google Sign-Out failed: $e");
        // Continue with other logout steps
      }

      // Sign out from Firebase
      try {
        await FirebaseAuth.instance.signOut();
        print("Firebase Sign-Out successful.");
      } catch (e) {
        print("Firebase Sign-Out failed: $e");
        // Continue with other logout steps
      }

      // Remove JWT tokens
      try {
        await _tokenStorage.deleteTokens();
        print("JWT tokens removed.");
      } catch (e) {
        print("Token removal failed: $e");
        // Continue with navigation
      }

      // Clear all shared preferences data
      await _prefsClearService.clearAllUserData();
      print("All shared preferences cleared");

      // Clear user data from AppConstants
      AppConstants.userId = '';
      AppConstants.userName = '';
      
      print("Cleared user data from AppConstants");

      // Navigate to onboarding screen
      Get.offAllNamed('/onboarding');
      print("Sign out process completed");
    } catch (e) {
      print("Sign-Out Error: $e");
      // Still try to navigate to onboarding screen even if there's an error
      Get.offAllNamed('/onboarding');
    }
  }



  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasValidTokens();
  }

  // Deactivate Account
  Future<void> deactivateAccount() async {
    try {
      print("Starting account deactivation...");
      
      // Call backend to deactivate account
      await _apiService.deactivateAccount();
      print("Account deactivation successful");

      // Clear all shared preferences before sign out
      await _prefsClearService.clearAllUserData();
      print("All shared preferences cleared during deactivation");

      // Sign out from all services
      await signOut();
    } catch (e) {
      print("Account Deactivation Error: $e");
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      print("Starting account deletion...");
      
      // Call backend to delete account
      await _apiService.deleteAccount();
      print("Account deletion successful");

      // Clear all shared preferences before sign out
      await _prefsClearService.clearAllUserData();
      print("All shared preferences cleared during deletion");

      // Sign out from all services
      await signOut();
    } catch (e) {
      print("Account Deletion Error: $e");
      rethrow;
    }
  }
}
