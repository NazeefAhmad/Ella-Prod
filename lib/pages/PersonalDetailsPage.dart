
import 'package:flutter/material.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:get/get.dart';



class PersonalDetailsController extends GetxController {
  var name = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;
  var otherGender = ''.obs;
  var email = ''.obs;

  void onContinue() {
    // Validation
    if (name.value.isEmpty || dob.value.isEmpty || gender.value.isEmpty || email.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!isValidEmail(email.value)) {
      Get.snackbar('Error', 'Invalid email format', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed('/home'); // Navigate to HomePage
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}



class PersonalDetailsPage extends StatelessWidget {
  final PersonalDetailsController controller = Get.put(PersonalDetailsController());
  final TextEditingController dobController = TextEditingController();

  // Header Text Widget
  
  Widget _buildHeaderText() {
    return const Text(
      "Let’s get to know you!",
      style: TextStyle(
        fontSize: 34, // Adjusted font size
        fontWeight: FontWeight.bold,
        color: Colors.black, // Changed color for visibility
        letterSpacing: 1.6, // Adjusted letter spacing
      ),
    );
  }

  // Date of Birth Input Field with constraints
  Widget _buildDOBField(BuildContext context) {
    return TextField(
      controller: dobController,
      decoration: InputDecoration(
        labelText: 'Date of Birth (dd-mm-yyyy)',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime firstDate = DateTime(1900);
        DateTime lastDate = DateTime(now.year, now.month, now.day);

        // Show date picker
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.indigoAccent,
                hintColor: Colors.indigoAccent,
                colorScheme: ColorScheme.light(primary: Colors.indigoAccent),
                buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child ?? Container(),
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate = '${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}';
          controller.dob.value = formattedDate;
          dobController.text = formattedDate;
        }
      },
    );
  }

  // Gender Selection Card Widget
  Widget _buildGenderCard(String genderOption) {
    Color selectedColor;
    Color textColor = Colors.black87;
    Color backgroundColor = Colors.white;

    switch (genderOption) {
      case "Male":
        selectedColor = Colors.blue;
        break;
      case "Female":
        selectedColor = Colors.pink;
        break;
      case "Others":
        selectedColor = Colors.purple;
        break;
      default:
        selectedColor = Colors.white;
        break;
    }

    return GestureDetector(
      onTap: () {
        controller.gender.value = genderOption;
        if (genderOption != "Others") {
          controller.otherGender.value = ''; // Reset 'Others' input if a different option is selected
        }
      },
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: controller.gender.value == genderOption ? selectedColor : backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              genderOption,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.gender.value == genderOption ? Colors.white : textColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  // Common Input Field Widget
  Widget _buildInputField(BuildContext context, String label, {required IconData icon, required Function(String) onChanged, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.indigoAccent),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: errorText,
          ),
          onChanged: onChanged,
        ),
        if (errorText != null) // Show error message below the input field
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  // Continue Button Widget
  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: controller.onContinue,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
      child: const Text(
        'Continue',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(250, 251, 254, 1),
                  Color.fromRGBO(218, 229, 249, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(),
                const SizedBox(height: 24),
                _buildInputField(
                  context,
                  "Full Name",
                  icon: Icons.person,
                  onChanged: (value) => controller.name.value = value,
                ),
                const SizedBox(height: 24),
                // Date of Birth
                _buildDOBField(context),
                const SizedBox(height: 32),
                // Gender Selection
                const Text(
                  "Gender",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildGenderCard("Male")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildGenderCard("Female")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildGenderCard("Others")),
                  ],
                ),
                if (controller.gender.value == "Others") // Show input field if "Others" is selected
                  _buildInputField(
                    context,
                    "Please specify",
                    icon: Icons.edit,
                    onChanged: (value) => controller.otherGender.value = value,
                  ),
                const SizedBox(height: 24),
                _buildInputField(
                  context,
                  "Email",
                  icon: Icons.email,
                  onChanged: (value) => controller.email.value = value,
                ),
                const SizedBox(height: 24),
                _buildContinueButton(), // Continue Button
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
