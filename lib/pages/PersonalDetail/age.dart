// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
// // import 'package:gemini_chat_app_tutorial/pages/UserInterestPage.dart';
// import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';



// class AgePage extends StatefulWidget {
//   const AgePage({Key? key}) : super(key: key);

//   @override
//   _AgePageState createState() => _AgePageState();
// }

// class _AgePageState extends State<AgePage> {
//   final TextEditingController _ageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("What's your age?"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter your age',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _ageController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your age',
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               ),
//               keyboardType: TextInputType.number,
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 50),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_ageController.text.isNotEmpty) {
//                     Get.toNamed('/userInterest'); // Go to PersonalDetailsPage
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Please enter your age!")),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   shape: CircleBorder(),
//                   padding: EdgeInsets.all(20),
//                 ),
//                 child: const Icon(Icons.arrow_forward, size: 30),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';

// class AgePage extends StatefulWidget {
//   const AgePage({Key? key}) : super(key: key);

//   @override
//   _AgePageState createState() => _AgePageState();
// }

// class _AgePageState extends State<AgePage> {
//   final TextEditingController _ageController = TextEditingController();
//   bool isOver18 = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 20,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             SizedBox(width: 5),
//             Container(
//               width: 20,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             SizedBox(width: 5),
//             Container(
//               width: 20,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ],
//         ),
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'What’s your age?',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _ageController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your age',
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               ),
//               keyboardType: TextInputType.number,
//               style: TextStyle(fontSize: 18),
//               onChanged: (value) {
//                 if (value.isNotEmpty && int.tryParse(value) != null) {
//                   setState(() {
//                     isOver18 = int.parse(value) >= 18;
//                   });
//                 } else {
//                   setState(() {
//                     isOver18 = false;
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(
//                       color: isOver18 ? Colors.transparent : Colors.grey,
//                       width: 2,
//                     ),
//                     color: isOver18 ? Colors.red : Colors.white,
//                   ),
//                   child: isOver18
//                       ? Icon(
//                           Icons.check,
//                           size: 16,
//                           color: Colors.white,
//                         )
//                       : null,
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Yes, I am over 18',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             ElevatedButton(
//               onPressed: isOver18
//                   ? () {
//                       if (_ageController.text.isNotEmpty) {
//                         Get.to(() => UserInterestPage());
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Please enter your age!")),
//                         );
//                       }
//                     }
//                   : null,
//               child: Text('Continue'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isOver18 ? Colors.red : Colors.grey,
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';

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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 32, 78, 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 8,
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
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Let's keep things\nage-appropriate!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.grey,
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
                           mainAxisAlignment: MainAxisAlignment.center, // Centers the Row horizontally
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isOver18 ? Color.fromRGBO(255, 32, 71, 1) : Color.fromRGBO(217, 217, 217, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isOver18
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : const Icon(Icons.check, color: Colors.white,),
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
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: isOver18 ? Color.fromRGBO(255, 32, 71, 1) :Color.fromRGBO(217, 217, 217, 1) ,
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
                      color: isOver18 ? Colors.white : Color.fromRGBO(140, 140, 140, 1) ,
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