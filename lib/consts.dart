class AppConstants {
  // For local development, use your computer's IP address
  // Make sure your mobile device is on the same network
  // static String baseUrl = 'http://192.168.1.19:8000';

  static String baseUrl = 'http://192.168.1.22:8000';  // Use the deployed server URL
  
  // For production, use your deployed server URL
 //  static String baseUrl = 'https://hoocup.onrender.com';

  static String deviceId = '';  // Initialize as empty string
  static String accessToken = 'accessToken';
  static String fcmtoken = '';
  
  static String userName = '';  // Store the username
  static String genderPreference = 'genderPreference';  // Store the gender preference
  static String interest = ''; // Or you can initialize it to a default value
  static String deviceFingerprint = '';  // Initialize as empty string  
  static String firebaseUid = '';  // Store the Firebase UID
  static String userId = firebaseUid;  // Store the user ID, initially same as firebaseUid
}
//check Now 