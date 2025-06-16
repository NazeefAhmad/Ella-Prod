import 'package:flutter/material.dart';

class NoInternetIndicator extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isChecking;

  const NoInternetIndicator({
    super.key,
    required this.onRetry,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Full screen image
            Positioned.fill(
              child: Image.asset(
                'assets/images/no_internet.png',
                fit: BoxFit.fill,
              ),
            ),
            // Content overlay
            Positioned.fill(
              child: Container(
               
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // const Text(
                      //   'No Internet Connection',
                      //   style: TextStyle(
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black87,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Please check your connection and try again',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     color: Colors.black54,
                      //     height: 1.5,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                     
                      SizedBox(
                        width: double.infinity,
                        height: 57,
                        child: ElevatedButton(
                          onPressed: isChecking ? null : onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 32, 78, 1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isChecking
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.25), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 