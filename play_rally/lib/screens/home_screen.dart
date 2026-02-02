import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';

/// Home Screen - Two main options with lavender Apple-style design
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'PlayRally',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pickleball Scoring Made Simple',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              
              // Option buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionCard(
                    icon: Icons.sports_tennis,
                    title: 'Score\nMatch',
                    onTap: () => Get.toNamed(Routes.gameFormat),
                  ),
                  const SizedBox(width: 32),
                  _buildOptionCard(
                    icon: Icons.stream,
                    title: 'Stream\nMatch',
                    isComingSoon: true,
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.construction, color: AppColors.primary),
                              const SizedBox(width: 10),
                              const Text('Coming Soon'),
                            ],
                          ),
                          content: const Text('Stream Match feature is under development.'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('OK', style: TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient accent at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isComingSoon
                        ? [AppColors.accent, AppColors.accentLight]
                        : [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isComingSoon ? AppColors.accentLight : AppColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: isComingSoon ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isComingSoon ? AppColors.textSecondary : AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Coming soon badge
            if (isComingSoon)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Soon',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
