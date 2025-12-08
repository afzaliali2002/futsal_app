import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context, String title, String content) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Text(content, textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تایید'),
            ),
          ],
        ),
      ],
    ),
  );
}
