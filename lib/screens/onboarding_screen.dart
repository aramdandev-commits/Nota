import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/onboarding_data.dart';
import 'package:nota/widgets/custom_page_indicator.dart';
import 'package:nota/widgets/onboarding_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static String id = "OnboardingScreen";

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static PageController controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x0A0E1A),
      appBar: AppBar(
        backgroundColor: Color(0x0A0E1A),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/nota.png'),
            SizedBox(width: 8),
            Text(
              'Nota',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Inter',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.language)),
          SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("onboardingSeen", true);
              context.go("/home");
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: onboardingList.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(onboardingList[index].image),
                      Text(
                        onboardingList[index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingList[index].description,
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Indicator
            CustomPageIndicator(
              controller: controller,
              itemCount: onboardingList.length,
            ),
            const SizedBox(height: 20),
            // Button
            OnboardingButton(
              controller: controller,
              totalPages: onboardingList.length,
              currentIndex: currentIndex,
              onGetStarted: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool("onboardingSeen", true);
                context.go("/home");
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
