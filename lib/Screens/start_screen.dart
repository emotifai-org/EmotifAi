import 'package:emotifai/Screens/login_screen.dart';
import 'package:emotifai/Screens/registraion_screen.dart';
import 'package:emotifai/Widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        exitApp();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, right: 24.0),
                  child: IconButton(
                    onPressed: () {
                      exitApp();
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 58),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to EmotifAi',
                    style: GoogleFonts.lato(
                      color: Color(0xFFFFFFFF).withOpacity(0.87),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Please login to your account or create new account to continue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: Color(0xFFFFFFFF).withOpacity(0.87),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  right: 24.0,
                  left: 24,
                  bottom: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 368,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => LoginScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white, // White background
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            // Sharp corners
                          ),
                        ),
                        child: Text(
                          'LOGIN',
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ), // Black text
                      ),
                    ),
                    SizedBox(height: 28),
                    SizedBox(
                      width: 368,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => RegistrationScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(4),
                          ),
                        ),
                        child: Text(
                          'CREATE ACCOUNT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
