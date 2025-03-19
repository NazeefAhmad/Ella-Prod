import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In process...");

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return null; // User canceled sign-in
      }

      print("Google user authenticated: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Google authentication obtained: "
          "AccessToken: ${googleAuth.accessToken}, IDToken: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in with credentials...");

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("Sign-in successful. User: ${userCredential.user?.email}");

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
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
    } catch (e) {
      print("Sign-Out Error: $e");
    }
  }
}
