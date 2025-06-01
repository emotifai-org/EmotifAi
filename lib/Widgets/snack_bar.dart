import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Color? backgroundColor, // Your app's purple
}) {
  final bgcolor = backgroundColor ?? Colors.grey[900];
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: bgcolor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
      duration: const Duration(seconds: 5),
      elevation: 6,
      margin: const EdgeInsets.all(16),
    ),
  );
}
