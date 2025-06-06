import 'package:flutter/material.dart';
import 'on_boarding_screen1.dart';
import 'on_boarding_screen2.dart';
import 'on_boarding_screen3.dart';
import 'on_boarding_screen4.dart';
import '../start_screen.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = const [
    OnBoardingScreen1(),
    OnBoardingScreen2(),
    OnBoardingScreen3(),
    OnBoardingScreen4(),
  ];

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (route) => false,
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _skip();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _controller.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Optionally: SystemNavigator.pop(); or do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top "Skip" button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 24.0),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: _pages,
              ),
            ),
            // Single page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  width: 24,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white.withOpacity(0.87)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _back,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.44),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'NEXT',
                    ),
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
