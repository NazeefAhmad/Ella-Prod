import 'package:flutter/material.dart';
import '../services/version_service.dart';

class UpdateDialog extends StatelessWidget {
  final bool isForceUpdate;
  final VersionService versionService;

  const UpdateDialog({
    Key? key,
    required this.isForceUpdate,
    required this.versionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isForceUpdate,
      child: AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A new version of the app is available. Please update to continue using the app.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (!isForceUpdate)
              const Text(
                'You can update now or later.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () async {
              await versionService.launchStore();
              if (!isForceUpdate) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
} 