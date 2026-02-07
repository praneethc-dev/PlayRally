import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scoring_controller.dart';
import '../utils/constants.dart';

/// Player Details Screen - Fully responsive for all devices
class PlayerDetailsScreen extends StatefulWidget {
  const PlayerDetailsScreen({super.key});

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  final ScoringController controller = Get.find<ScoringController>();
  
  final TextEditingController redPlayer1 = TextEditingController();
  final TextEditingController redPlayer2 = TextEditingController();
  final TextEditingController bluePlayer1 = TextEditingController();
  final TextEditingController bluePlayer2 = TextEditingController();

  bool get isDoubles => controller.gameType.value == 'Doubles';

  @override
  void dispose() {
    redPlayer1.dispose();
    redPlayer2.dispose();
    bluePlayer1.dispose();
    bluePlayer2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background, // Fallback
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)], // Light Blue Mist Gradient
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final isCompact = availableHeight < 350;
              final headerHeight = isCompact ? 40.0 : 50.0;
              final buttonHeight = isCompact ? 40.0 : 50.0;
              final cardPadding = isCompact ? 10.0 : 16.0;
              final verticalSpacing = isCompact ? 8.0 : 16.0;
              
              // Calculate remaining space for cards
              double availableForCards = availableHeight - headerHeight - buttonHeight - (verticalSpacing * 2);
              
              // Ensure minimum height for cards to prevent overflow/squashing inputs
              // Badge(~30) + 2 Inputs(~100) + Spacing + Padding -> ~200-250 needed
              double minCardHeight = 260.0; 
              
              // Use the larger of available space or minimum height
              final cardRowHeight = availableForCards < minCardHeight ? minCardHeight : availableForCards;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 20,
                    vertical: isCompact ? 6 : 12,
                  ),
                  child: Column(
                    children: [
                      // Header - Fixed height
                      SizedBox(
                        height: headerHeight,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5), // Glassy button
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
                                child: Icon(Icons.arrow_back_ios_new, size: isCompact ? 14 : 18, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Player Details', style: TextStyle(
                                fontSize: isCompact ? 18 : 22,
                                fontWeight: FontWeight.w800, // Bolder title
                                color: AppColors.textPrimary,
                              )),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: verticalSpacing), 

                      // Team cards - Dynamic height
                      SizedBox(
                        height: cardRowHeight,
                        child: Row(
                          children: [
                            Expanded(child: _buildTeamCard('Team Red', AppColors.teamRed, redPlayer1, isDoubles ? redPlayer2 : null, cardPadding, isCompact)),
                            SizedBox(width: isCompact ? 10 : 16),
                            Expanded(child: _buildTeamCard('Team Blue', AppColors.teamBlue, bluePlayer1, isDoubles ? bluePlayer2 : null, cardPadding, isCompact)),
                          ],
                        ),
                      ),

                      SizedBox(height: verticalSpacing),

                      // Start button - Fixed height
                      SizedBox(
                        height: buttonHeight,
                        child: GestureDetector(
                          onTap: _onStartMatch,
                          child: Container(
                            width: screenWidth * 0.45, // Slightly wider
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4), 
                                  blurRadius: 12, 
                                  offset: const Offset(0, 6)
                                )
                              ],
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: isCompact ? 18 : 24),
                                const SizedBox(width: 8),
                                Text('Start Match', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isCompact ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(String teamName, Color teamColor, TextEditingController p1, TextEditingController? p2, double padding, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Glassy white
        borderRadius: BorderRadius.circular(24), // Larger radius
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Team badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20, vertical: isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: teamColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3)
                )
              ],
            ),
            child: Text(teamName, style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
          ),
          
          // Player 1 input
          _buildInput(p1, 'Player 1', isCompact),
          
          // Player 2 input (doubles)
          if (p2 != null)
            _buildInput(p2, 'Player 2', isCompact)
          else
             // Spacer to balance height in Singles if needed, or just shrink
             const SizedBox.shrink(), // Or Spacer() if we want inputs fixed at certain spots? Let's keep shrink for now.
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, bool isCompact) {
    return Container(
      height: isCompact ? 36 : 48, // Slightly taller inputs
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // Semi-transparent input bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isCompact ? 12 : 15, 
          color: AppColors.textPrimary, 
          fontWeight: FontWeight.w600
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.8), 
            fontSize: isCompact ? 11 : 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isCompact ? 8 : 12), // Centered vertically roughly
          isDense: true,
        ),
      ),
    );
  }

  void _onStartMatch() {
    if (redPlayer1.text.trim().isEmpty || bluePlayer1.text.trim().isEmpty) {
      Get.snackbar('Missing', 'Enter player names', snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary, colorText: Colors.white, margin: const EdgeInsets.all(10), borderRadius: 8);
      return;
    }
    
    if (isDoubles && (redPlayer2.text.trim().isEmpty || bluePlayer2.text.trim().isEmpty)) {
      Get.snackbar('Missing', 'Enter all player names', snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary, colorText: Colors.white, margin: const EdgeInsets.all(10), borderRadius: 8);
      return;
    }

    controller.setPlayers(
      redPlayer1: redPlayer1.text.trim(),
      redPlayer2: isDoubles ? redPlayer2.text.trim() : null,
      bluePlayer1: bluePlayer1.text.trim(),
      bluePlayer2: isDoubles ? bluePlayer2.text.trim() : null,
    );
    
    Get.offNamed(Routes.scoring);
  }
}
