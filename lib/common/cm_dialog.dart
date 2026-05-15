import 'package:flutter/material.dart';

class CmDialog {
  static Future<void> showBannedDialog(BuildContext context, {String? banEndDate,VoidCallback? onPressed}) async {
    String durationMessage = banEndDate != null
        ? "This suspension is active until: $banEndDate"
        : "This is a permanent deactivation.";

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_person_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Account Banned"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "An Administrator has restricted your access to the Gasket Guy platform.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                durationMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "If you believe this is an error, please reach out to system support.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: const Text("CLOSE"),
          ),
        ],
      ),
    );
  }
}