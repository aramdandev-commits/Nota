import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/onboarding_data.dart';
import 'package:nota/widgets/spa/custom_page_indicator.dart';
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/nota.png'),
            const SizedBox(width: 8),
            Text(
              'Nota',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Inter',
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.language, color: cs.onSurface)),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("onboardingSeen", true);
              if (!context.mounted) return;
              context.go("/auth");
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                fontSize: 14,
                color: cs.onSurface,
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
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: cs.onSurface,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingList[index].description,
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          color: cs.onSurface.withValues(alpha: 0.6),
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
                if (!context.mounted) return;
                context.go("/auth");
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
