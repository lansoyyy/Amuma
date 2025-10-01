import 'package:flutter/material.dart';
import 'package:amuma/services/auth_service.dart';
import 'package:amuma/screens/auth_screen.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/utils/colors.dart';

class LogoutWidget {
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Logout Confirmation',
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Are you sure you want to logout?',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Regular',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog first

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Perform logout
              final result = await AuthService().signOut();

              // Close loading indicator
              Navigator.of(context).pop();

              // Navigate to auth screen
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );

                // Show logout message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.isSuccess ? healthGreen : healthRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: TextWidget(
              text: 'Logout',
              fontSize: 14,
              color: healthRed,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }
}
