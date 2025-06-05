// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AdditionalResourcesScreen extends StatelessWidget {
//   const AdditionalResourcesScreen({Key? key}) : super(key: key);

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   Widget _buildOptionItem(BuildContext context, String title, {Color? textColor}) {
//     return ListTile(
//       title: Text(
//         title,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           color: textColor ?? Colors.black,
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       onTap: () {
//         String url = 'https://hoocup.fun';
//         _launchURL(url);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Additional Resources',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildOptionItem(
//               context,
//               'Privacy Policy',
//             ),
//             const Divider(height: 1),
//             _buildOptionItem(
//               context,
//               'Terms and Conditions',
//             ),
//             const Divider(height: 1),
//             _buildOptionItem(
//               context,
//               'Report a Problem',
//               textColor: Colors.red,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../widgets/back_button.dart';

// WebViewScreen to display the URL in an in-app web view
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load page: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// AdditionalResourcesScreen modified to use WebViewScreen
class AdditionalResourcesScreen extends StatelessWidget {
  const AdditionalResourcesScreen({Key? key}) : super(key: key);

  Widget _buildOptionItem(BuildContext context, String title, {Color? textColor, required String url}) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: url,
              title: title,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Additional Resources',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(
              context,
              'Privacy Policy',
              url: 'https://hoocup.fun/privacy-policy',
            ),
            const Divider(height: 1),
            _buildOptionItem(
              context,
              'Terms and Conditions',
              url: 'https://hoocup.fun/terms-and-conditions',
            ),
            const Divider(height: 1),
           
    
            _buildOptionItem(
              context,
              'Contact Us',
              url: 'https://www.exampl.com',
            ),
            const Divider(height: 1),
            _buildOptionItem(
              context,
              'About Team Hoocup',
              url: 'https://www.exampl.com',
            ),
             const Divider(height: 1),
             _buildOptionItem(
              context,
              'Report a Problem',
              textColor: Colors.red,
              url: 'https://hoocup.fun/report-a-problem',
            ),
          ],
        ),
      ),
    );
  }
}
