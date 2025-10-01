import 'package:flutter/material.dart';
import 'package:naivedhya/screens/bottom_navigator/bottom_navigator.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import '../../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/Onboard_screen_images/11.jpg',
      'title': 'Welcome to Naivedhya',
      'description': 'Discover delicious meals from our restaurants.',
    },
    {
      'image': 'assets/Onboard_screen_images/22.jpg',
      'title': 'Fast Delivery',
      'description': 'Track your order in real-time.',
    },
    {
      'image': 'assets/Onboard_screen_images/33.jpg',
      'title': 'Enjoy Your Meal',
      'description': 'Multiple payment options for your convenience.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.6,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Image.asset(
                      _onboardingData[index]['image']!,
                      height: screenHeight * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _onboardingData[_currentPage]['title']!,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _onboardingData[_currentPage]['description']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (_currentPage < _onboardingData.length - 1)
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const BottomNavigator()),
                            );
                          },
                          child: const Text('Skip'),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const BottomNavigator()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}