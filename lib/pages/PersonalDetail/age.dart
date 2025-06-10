import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';
import '../../widgets/back_button.dart';

class AgePage extends StatefulWidget {
  const AgePage({Key? key}) : super(key: key);

  @override
  _AgePageState createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  bool isOver18 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Back Button and Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 32, 78, 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 64),
                    const Text(
                      "Are you 18+ ?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Let's keep things age-appropriate!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 54),
                    
                    // Age Verification Option
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isOver18 = !isOver18;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isOver18
                                    ? Color.fromRGBO(255, 32, 71, 1)
                                    : Color.fromRGBO(217, 217, 217, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isOver18
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : const Icon(Icons.check, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "Yes, I am over 18",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Consent Text with Links
            const ConsentText(),
                
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 240,
                height: 59,
                decoration: BoxDecoration(
                  color: isOver18
                      ? Color.fromRGBO(255, 32, 71, 1)
                      : Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: isOver18
                      ? () {
                          Get.to(() => UserInterestPage());
                        }
                      : null,
                  child: Text(
                    "Continue",
                  
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: isOver18
                          ? Colors.white
                          : Color.fromRGBO(140, 140, 140, 1),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// Consent Text Widget
class ConsentText extends StatelessWidget {
  const ConsentText({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "By clicking 'Continue', I agree to Hoocup's\n",
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        children: [
          TextSpan(
            text: 'Terms & Conditions',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.grey,
              fontSize: 12,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl('https://hoocup.fun/terms-and-conditions'),
          ),
          const TextSpan(
            text: ' and ',
            style: TextStyle(fontSize: 12),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.grey,
              fontSize: 12,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl('https://hoocup.fun/privacy-policy'),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}