import 'package:flutter/material.dart';
import '../services/version_service.dart';

class UpdateDialog extends StatelessWidget {
  final bool isForceUpdate;
  final VersionService versionService;
  final String? updateMessage;
  final String? updateUrl;

  const UpdateDialog({
    super.key,
    required this.isForceUpdate,
    required this.versionService,
    this.updateMessage,
    this.updateUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate,
      child: AlertDialog(
        title: Text(isForceUpdate ? 'Update Required' : 'Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateMessage ?? 'A new version of the app is available. Please update to continue using the app.',
              style: const TextStyle(fontSize: 16),
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
              try {
                if (updateUrl != null && updateUrl!.isNotEmpty) {
                  // Use custom update URL from backend
                  await versionService.launchUpdateUrl(updateUrl!);
                } else {
                  // Fall back to default app store
                  await versionService.launchStore();
                }
                if (!isForceUpdate && context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // Show error message if URL launch fails
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to open update link: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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