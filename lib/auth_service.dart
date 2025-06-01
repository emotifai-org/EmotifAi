import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emotifai/Screens/HomeScreen/home_screen.dart';
import 'package:emotifai/Screens/login_screen.dart';
import 'package:emotifai/Widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerWithEmail(
    BuildContext context,
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'username': username, 'email': email});
      await userCredential.user!.sendEmailVerification();
      await _auth.signOut();
      showCustomSnackBar(
        context,
        message:
            'Verification email sent. Please verify to activate your account.',
      );
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
    }
  }

  Future<void> loginWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.reload(); // Refresh verification status
      User? user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        FocusScope.of(context).unfocus(); // Closes keyboard
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        final unverifiedUser = FirebaseAuth.instance.currentUser;

        showCustomSnackBar(
          context,
          message: 'Account not verified. Please complete verification first.',
          icon: Icons.info_outline,
          actionLabel: 'Resend',
          onAction: () async {
            try {
              if (unverifiedUser != null && !unverifiedUser.emailVerified) {
                await unverifiedUser.sendEmailVerification();
                showCustomSnackBar(
                  context,
                  message: 'Verification email resent!',
                  icon: Icons.check_circle_outline,
                  backgroundColor: Colors.green,
                );
              } else {
                showCustomSnackBar(
                  context,
                  message: 'User already verified or not found.',
                  icon: Icons.info_outline,
                  backgroundColor: Colors.orange,
                );
              }
            } catch (e) {
              showCustomSnackBar(
                context,
                message: 'Failed to resend verification email.',
                icon: Icons.error_outline,
                backgroundColor: Colors.redAccent,
              );
            }
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
    }
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        showCustomSnackBar(
          context,
          message: 'New verification email sent.',
          icon: Icons.check_circle_outline,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        context,
        message: 'Failed to resend verification email.',
        icon: Icons.error_outline,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  void _handleAuthError(BuildContext context, FirebaseAuthException e) {
    String message = 'Operation failed';
    print('FirebaseAuthException code: ${e.code}');
    switch (e.code) {
      case 'email-already-in-use':
        message = 'Email already registered';
        break;
      case 'invalid-email':
        message = 'Invalid email format';
        break;
      case 'weak-password':
        message = 'Password too weak (min 6 chars)';
        break;
      case 'user-not-found':
        message = 'Account not found';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please check your credentials.';
        break;
    }
    showCustomSnackBar(context, message: message);
  }
}
