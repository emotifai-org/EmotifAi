import 'package:emotifai/Screens/OnBoardingScreen/on_boarding_screen1.dart';
import 'package:emotifai/Screens/OnBoardingScreen/on_boarding_screen3.dart';
import 'package:emotifai/Screens/OnBoardingScreen/on_boarding_screen2.dart';
import 'package:emotifai/Screens/OnBoardingScreen/on_boarding_screen4.dart';
import 'package:emotifai/Screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<Widget> onBoardingScreen = [
  OnBoardingScreen1(),
  OnBoardingScreen2(),
  OnBoardingScreen3(),
  OnBoardingScreen4(),
];

void goToNextOnboarding(BuildContext context, int curretIndex) {
  if (curretIndex < onBoardingScreen.length - 1) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => onBoardingScreen[curretIndex + 1],
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => StartScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }
}

void goToPreviousOnboarding(BuildContext context, int currentIndex) {
  if (currentIndex > 0) {
    Navigator.pop(context);
  } else {
    SystemNavigator.pop();
  }
}

void skipOnboarding(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => StartScreen(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    (route) => false,
  );
}

Future<bool> exitApp() async {
  SystemNavigator.pop();
  return false; // Prevents further popping
}
