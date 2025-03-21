import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../controllers/theme_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Games',
      description:
          'Browse through a variety of team-building activities and games for your office team.',
      imagePath: 'assets/icons/all.svg',
      backgroundColor: AppTheme.primaryColor,
      iconData: Icons.search_rounded,
    ),
    OnboardingPage(
      title: 'Random Picker',
      description: 'Can\'t decide what to play? Let our random picker choose a game for you!',
      imagePath: 'assets/icons/active.svg',
      backgroundColor: AppTheme.teamBuildingColor,
      iconData: Icons.casino_rounded,
    ),
    OnboardingPage(
      title: 'Timer & Scoreboard',
      description: 'Keep track of time and scores during gameplay with our built-in tools.',
      imagePath: 'assets/icons/clock.svg',
      backgroundColor: AppTheme.quickGamesColor,
      iconData: Icons.timer_rounded,
    ),
    OnboardingPage(
      title: 'Leaderboard',
      description: 'Track performance and celebrate achievements with the team leaderboard.',
      imagePath: 'assets/icons/team.svg',
      backgroundColor: AppTheme.brainGamesColor,
      iconData: Icons.leaderboard_rounded,
    ),
  ];
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    // Start animation when screen loads
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.MAIN);
    }
  }

  void _onSkip() {
    Get.offAllNamed(AppRoutes.MAIN);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _animationController.reset();
                _animationController.forward();
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], size);
            },
          ),

          // Bottom controls with modern design
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator with enhanced styling
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentIndex].backgroundColor,
                      dotColor:
                          isDarkMode
                              ? Colors.grey.withOpacity(0.3)
                              : AppTheme.lightTextColor.withOpacity(0.3),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons with improved layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button with improved styling
                      TextButton(
                        onPressed: _onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode
                                  : AppTheme.lightTextColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Skip', style: TextStyle(fontSize: 16)),
                      ),

                      // Next/Done button with animation and enhanced styling
                      ElevatedButton(
                        onPressed: _onNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentIndex].backgroundColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex < _pages.length - 1 ? 'Next' : 'Get Started',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentIndex < _pages.length - 1 ? Icons.arrow_forward : Icons.check,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, Size size) {
    return Container(
      color: page.backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Page number indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${_pages.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Animated content
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image with improved styling
                    Container(
                      width: size.width * 0.6,
                      height: size.width * 0.6,
                      padding: EdgeInsets.all(size.width * 0.12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                      child: SvgPicture.asset(
                        page.imagePath,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),

                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(page.iconData, size: 30, color: page.backgroundColor),
                    ),
                    SizedBox(height: size.height * 0.03),

                    // Title with enhanced styling
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        page.title,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // Description with improved styling
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        page.description,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add more space at bottom to accommodate the controls
            SizedBox(height: size.height * 0.22),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final IconData iconData;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.iconData,
  });
}
