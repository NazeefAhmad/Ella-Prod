import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gemini_chat_app_tutorial/services/token_storage_service.dart';
import 'package:gemini_chat_app_tutorial/services/api_service.dart';
import 'package:get/get.dart';

class AuthService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final ApiService _apiService = ApiService();

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

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '683567834719-ubol9j6hpnr86rouff57k3o9uegrcpd9.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return null;
      }

      print("Google user authenticated: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("Google authentication obtained: "
          "AccessToken: ${googleAuth.accessToken}, IDToken: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in with credentials...");

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Get the Firebase ID token instead of using the Google ID token
      String? firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        throw 'Failed to get Firebase ID token';
      }

      print("Firebase ID token obtained: ${firebaseIdToken.substring(0, 20)}...");
      
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

      print("Sign-in successful. User: ${userCredential.user?.email}");
      print("Access Token: ${accessToken.substring(0, 20)}..."); // Log first 20 chars for debugging

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Guest Sign-In
  Future<bool> signInAsGuest() async {
    try {
      final response = await _apiService.continueAsGuest();
      
      // Validate JWT tokens before storing
      final accessToken = response['accessToken'] as String;
      final refreshToken = response['refreshToken'] as String;

      if (!_isValidJwtFormat(accessToken)) {
        throw 'Invalid access token format received from server';
      }
      if (!_isValidJwtFormat(refreshToken)) {
        throw 'Invalid refresh token format received from server';
      }

      print("Guest sign-in successful");
      print("Access Token: ${accessToken.substring(0, 20)}..."); // Log first 20 chars for debugging
      print("Refresh Token: ${refreshToken.substring(0, 20)}..."); // Log first 20 chars for debugging

      return true;
    } catch (e) {
      print("Guest Sign-In Error: $e");
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print("Signing out from Google...");
      await GoogleSignIn().signOut();
      print("Google Sign-Out successful.");

      await FirebaseAuth.instance.signOut();
      print("Firebase Sign-Out successful.");

      // Remove JWT tokens
      await _tokenStorage.deleteTokens();
      print("JWT tokens removed.");

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print("Sign-Out Error: $e");
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasValidTokens();
  }
}
