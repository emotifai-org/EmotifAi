import 'package:emotifai/Widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingScreen1 extends StatelessWidget {
  const OnBoardingScreen1({super.key});

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
                      'assets/images/mood.svg',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 51),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 27,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF).withOpacity(0.87),
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
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      'Welcome to EmotifAi',
                      style: GoogleFonts.montserrat(
                        color: Color(0xFFFFFFFF).withOpacity(0.87),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 42),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Discover music, activities, and events tailored to your mood.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          color: Color(0xFFFFFFFF).withOpacity(0.87),
                          fontSize: 18,
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
                      goToPreviousOnboarding(context, 0);
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
                    onPressed: () {
                      goToNextOnboarding(context, 0);
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
                    child: Text('NEXT', style: TextStyle(color: Colors.black)),
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
