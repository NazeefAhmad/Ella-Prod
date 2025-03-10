
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller for managing the state of the settings page
class SettingsController extends GetxController {
  // Observable variables
  var username = "John Doe".obs;
  var phoneNumber = "".obs;
  var notificationsEnabled = true.obs;
  var isDarkMode = false.obs;
  var selectedLanguage = "English".obs;
  var membershipStatus = "Free Tier Member".obs;

  // Method to verify phone number
  void verifyPhoneNumber() {
    Get.snackbar("Verification", "Verification link sent to ${phoneNumber.value}");
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            Divider(height: 40),
            _buildPhoneNumberSection(),
            Divider(height: 40),
            _buildNotificationsSection(),
            Divider(height: 40),
            _buildThemeSelection(),
            Divider(height: 40),
            _buildLanguageSelection(),
            Divider(height: 40),
            _buildMembershipInfo(),
            Divider(height: 40),
            _buildAdditionalOptions(),
          ],
        ),
      ),
    );
  }

  // Profile Section Widget
  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 30, color: Colors.grey[700]),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(controller.username.value, 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Text("Edit Profile", style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            // Logic to change profile photo or name
          },
        ),
      ],
    );
  }

  // Phone Number Section Widget
  Widget _buildPhoneNumberSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              controller.phoneNumber.value = value;
            },
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: controller.verifyPhoneNumber,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text('Verify', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Notifications Section Widget
  Widget _buildNotificationsSection() {
    return Obx(() {
      return SwitchListTile(
        title: Text('Enable Notifications', style: TextStyle(fontSize: 16)),
        value: controller.notificationsEnabled.value,
        activeColor: Colors.indigoAccent,
        onChanged: (value) {
          controller.notificationsEnabled.value = value;
        },
      );
    });
  }

  // Theme Selection Widget
  Widget _buildThemeSelection() {
    return Obx(() {
      return ListTile(
        title: Text('Theme', style: TextStyle(fontSize: 16)),
        trailing: DropdownButton<String>(
          value: controller.isDarkMode.value ? "Dark" : "Light",
          onChanged: (String? newValue) {
            controller.isDarkMode.value = (newValue == "Dark");
          },
          items: <String>['Light', 'Dark']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );
    });
  }

  // Language Selection Widget
  Widget _buildLanguageSelection() {
    return Obx(() {
      return ListTile(
        title: Text('Language', style: TextStyle(fontSize: 16)),
        trailing: DropdownButton<String>(
          value: controller.selectedLanguage.value,
          onChanged: (String? newValue) {
            controller.selectedLanguage.value = newValue!;
          },
          items: <String>['English', 'Spanish', 'French']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );
    });
  }

  // Membership Information Widget
  Widget _buildMembershipInfo() {
    return Obx(() {
      return ListTile(
        title: Text('Membership Status', style: TextStyle(fontSize: 16)),
        subtitle: Text(controller.membershipStatus.value,
            style: TextStyle(color: Colors.grey[700])),
      );
    });
  }

  // Additional Options Widget
  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOptionButton("Contact Us", Icons.contact_page, () {
          // Logic to navigate to Contact Us page
        }),
        SizedBox(height: 10),
        _buildOptionButton("Share App", Icons.share, () {
          // Logic to share the app link
        }),
        SizedBox(height: 10),
        _buildOptionButton("Terms and Conditions", Icons.policy, () {
          // Logic to open Terms and Conditions page
        }),
      ],
    );
  }

  // Helper method for option buttons
  Widget _buildOptionButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
