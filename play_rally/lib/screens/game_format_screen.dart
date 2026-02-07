import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scoring_controller.dart';
import '../utils/constants.dart';

/// Game Format Screen - Clean, Apple-styled layout with lavender theme
class GameFormatScreen extends StatefulWidget {
  const GameFormatScreen({super.key});

  @override
  State<GameFormatScreen> createState() => _GameFormatScreenState();
}

class _GameFormatScreenState extends State<GameFormatScreen> {
  String gameType = 'Doubles';
  int numberOfSets = 3;
  int playTo = 11;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth / 7;
    final isCompact = screenHeight < 400;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 32,
              vertical: isCompact ? 8 : 16,
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: () => Get.back(),
                        color: AppColors.primary,
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Setup',
                            style: TextStyle(
                              fontSize: isCompact ? 20 : 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (!isCompact)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Configure your match details',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'PlayRally',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isCompact ? 12 : 24),
                
                // Main content - Scrollable to prevent overflow
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left side
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSection('Game Type', ['Singles', 'Doubles'], gameType,
                                    (v) => setState(() => gameType = v), buttonWidth, isCompact),
                                SizedBox(height: isCompact ? 16 : 32),
                                _buildSection('Number of Sets', ['1', '3', '5'], numberOfSets.toString(),
                                    (v) => setState(() => numberOfSets = int.parse(v)), buttonWidth * 0.55, isCompact),
                              ],
                            ),
                          ),
                          
                          // Divider
                          Container(
                            width: 1.5,
                            height: 250, // Fixed height for consistency in scroll view
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                          
                          // Right side
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSection('Play To', ['11', '15'], playTo.toString(),
                                    (v) => setState(() => playTo = int.parse(v)), buttonWidth * 0.6, isCompact),
                                SizedBox(height: isCompact ? 16 : 32),
                                _buildInfoDisplay('Win By', '2 Points', isCompact),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Continue Button
                GestureDetector(
                  onTap: _onContinue,
                  child: Container(
                    width: screenWidth * 0.4,
                    padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 15 : 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 8 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String selected,
      Function(String) onSelect, double buttonWidth, bool isCompact) {
    return Column(
      children: [
        Text(title, style: TextStyle(
          fontSize: isCompact ? 13 : 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, // Darker text for glass
          letterSpacing: 0.3,
        )),
        SizedBox(height: isCompact ? 10 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options.map((option) {
            final isSelected = option == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onSelect(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: buttonWidth,
                  padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.5), // Glassy unselected
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(option, style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 13 : 14,
                    )),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoDisplay(String label, String value, bool isCompact) {
    return Column(
      children: [
        Text(label, style: TextStyle(
          fontSize: isCompact ? 13 : 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.3,
        )),
        SizedBox(height: isCompact ? 8 : 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: isCompact ? 10 : 12),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.accent),
          ),
          child: Text(value, style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 13 : 14,
          )),
        ),
      ],
    );
  }

  void _onContinue() {
    final controller = Get.find<ScoringController>();
    controller.setGameFormat(gameType: gameType, numberOfSets: numberOfSets, playTo: playTo);
    Get.toNamed(Routes.playerDetails);
  }
}
