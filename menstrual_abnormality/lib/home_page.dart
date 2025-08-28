import 'package:flutter/material.dart';
import 'package:menstrual_abnormality/app_theme.dart';
import 'package:menstrual_abnormality/widgets/theme_switch.dart';
import 'package:menstrual_abnormality/signup_page.dart';
import 'package:menstrual_abnormality/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "CycleSync",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : AppTheme.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: const [
          ThemeSwitch(),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              isDarkMode
                  ? Colors.black54
                  : AppTheme.lightColor.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20.0 : 28.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quote card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blueGrey.shade800
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "Understanding your cycle is the first step toward better health.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode
                            ? Colors.white
                            : AppTheme.primaryColor.withOpacity(0.9),
                        letterSpacing: 0.2,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Logo
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? AppTheme.primaryColor.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                          semanticLabel: 'App Logo',
                        ),
                      ),
                    ),
                  ),

                  // Heading
                  Center(
                    child: Text(
                      'Menstrual Abnormality\nDetection Using Cycle Pattern',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                        height: 1.3,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subheading
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Track, Analyze, and Monitor Your Menstrual Health',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black87.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Features - Responsive Layout
                  ResponsiveFeatures(
                    features: const [
                      FeatureData(icon: Icons.calendar_month, label: 'Track Cycles'),
                      FeatureData(icon: Icons.health_and_safety, label: 'Detect Patterns'),
                      FeatureData(icon: Icons.notifications_active, label: 'Get Alerts'),
                      FeatureData(icon: Icons.insights, label: 'View Insights'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Call-to-action
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Get Started Today',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join thousands of women monitoring their menstrual health',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                  AppTheme.primaryColor.withOpacity(0.8),
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignupPage()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 16.0),
                    child: Column(
                      children: [
                        Text(
                          '© 2025 CycleSync',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for features
class FeatureData {
  final IconData icon;
  final String label;

  const FeatureData({required this.icon, required this.label});
}

// Responsive Features Widget
class ResponsiveFeatures extends StatelessWidget {
  final List<FeatureData> features;

  const ResponsiveFeatures({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine if we should use grid layout or horizontal scroll
    // Use grid for larger screens (tablet/desktop) and horizontal scroll for mobile
    final useGridLayout = screenWidth > 600; // Tablet breakpoint
    final useHorizontalScroll = screenWidth < 500; // Mobile breakpoint

    if (useGridLayout) {
      // Grid layout for larger screens
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: features.map((feature) => FeatureItemGrid(
            icon: feature.icon,
            label: feature.label,
          )).toList(),
        ),
      );
    } else if (useHorizontalScroll) {
      // Horizontal scroll for very small screens
      return Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: features.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final feature = features[index];
            return FeatureItemHorizontal(
              icon: feature.icon,
              label: feature.label,
            );
          },
        ),
      );
    } else {
      // Two rows for medium screens
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FeatureItemGrid(
                    icon: features[0].icon,
                    label: features[0].label,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureItemGrid(
                    icon: features[1].icon,
                    label: features[1].label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureItemGrid(
                    icon: features[2].icon,
                    label: features[2].label,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureItemGrid(
                    icon: features[3].icon,
                    label: features[3].label,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

// Feature item widget for horizontal scroll
class FeatureItemHorizontal extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureItemHorizontal({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Feature item widget for grid layout
class FeatureItemGrid extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureItemGrid({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}