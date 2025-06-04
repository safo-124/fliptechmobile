// lib/shared_widgets/loading_dialog.dart
import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<void> show(BuildContext context, {String message = 'Processing...'}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must not close it manually
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          content: Row(
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 20),
              Text(message, style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Ensure it pops the top-most dialog
  }
}