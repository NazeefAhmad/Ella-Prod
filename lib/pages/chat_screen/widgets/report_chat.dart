import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';

class ReportChatDialog extends StatefulWidget {
  final String chatId;
  final String messageId;
  final String reporterId;

  const ReportChatDialog({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.reporterId,
  });

  @override
  State<ReportChatDialog> createState() => _ReportChatDialogState();
}

class _ReportChatDialogState extends State<ReportChatDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Reason required', 'Please enter a reason for reporting.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _isLoading = true);
    final apiService = ApiService();
    final success = await apiService.reportBotMessage(
      chatId: widget.chatId,
      messageId: widget.messageId,
      reason: reason,
      reporterId: widget.reporterId,
    );
    setState(() => _isLoading = false);
    if (success) {
      Get.back();
      Get.snackbar('Reported', 'Thank you for your report. Our team will review it.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade50, colorText: Colors.black);
    } else {
      Get.snackbar('Failed', 'Could not submit report. Please try again later.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade50, colorText: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Report Bot Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

