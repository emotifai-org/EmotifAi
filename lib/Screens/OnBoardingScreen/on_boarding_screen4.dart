import 'package:emotifai/Widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class OnBoardingScreen4 extends StatelessWidget {
  const OnBoardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 24.0),
                child: TextButton(
                  onPressed: () {
                    skipOnboarding(context);
                  },
                  child: Text(
                    'SKIP',
                    style: GoogleFonts.lato(
                      color: Color(0xFFFFFFFF).withOpacity(0.44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/permission.svg',
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 51),
                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 27,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: 2,
                          width: 27,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: 2,
                          width: 27,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: 2,
                          width: 27,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF).withOpacity(0.87),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      'Ready to Begin?',
                      style: GoogleFonts.montserrat(
                        color: Color(0xFFFFFFFF).withOpacity(0.87),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 42),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        '“We’ll need camera and microphone access to detect your mood. Your privacy matters.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          color: Color(0xFFFFFFFF).withOpacity(0.87),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      goToPreviousOnboarding(context, 3);
                    },
                    child: Text(
                      'Back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: Color(0xFFFFFFFF).withOpacity(0.44),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      bool granted = await requestCameraAndMicPermissions(
                        context,
                      );
                      if (granted && context.mounted) {
                        goToNextOnboarding(context, 3);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white, // White background
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Sharp corners
                      ),
                    ),
                    child: Text(
                      'Allow & Get Started',
                      style: TextStyle(color: Colors.black),
                    ), // Black text
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> requestCameraAndMicPermissions(BuildContext context) async {
  final statuses = await [Permission.camera, Permission.microphone].request();

  final allGranted = statuses.values.every((status) => status.isGranted);

  if (!allGranted && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Camera and microphone permissions are required"),
      ),
    );
  }

  return allGranted;
}
