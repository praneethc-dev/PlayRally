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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isCompact = availableHeight < 350;
            final headerHeight = isCompact ? 40.0 : 50.0;
            final buttonHeight = isCompact ? 40.0 : 50.0;
            final cardPadding = isCompact ? 10.0 : 16.0;
            
            return Padding(
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
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
                            ),
                            child: Icon(Icons.arrow_back_ios_new, size: isCompact ? 14 : 18, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Player Details', style: TextStyle(
                            fontSize: isCompact ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          )),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: isCompact ? 4 : 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(controller.gameType.value, 
                            style: TextStyle(fontSize: isCompact ? 10 : 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isCompact ? 8 : 14),

                  // Team cards - Takes remaining space
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildTeamCard('Team A', AppColors.teamRed, redPlayer1, isDoubles ? redPlayer2 : null, cardPadding, isCompact)),
                        SizedBox(width: isCompact ? 10 : 16),
                        Expanded(child: _buildTeamCard('Team B', AppColors.teamBlue, bluePlayer1, isDoubles ? bluePlayer2 : null, cardPadding, isCompact)),
                      ],
                    ),
                  ),

                  SizedBox(height: isCompact ? 8 : 12),

                  // Start button - Fixed height
                  SizedBox(
                    height: buttonHeight,
                    child: GestureDetector(
                      onTap: _onStartMatch,
                      child: Container(
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: isCompact ? 18 : 22),
                            const SizedBox(width: 6),
                            Text('Start Match', style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 13 : 15,
                              fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamCard(String teamName, Color teamColor, TextEditingController p1, TextEditingController? p2, double padding, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Team badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: isCompact ? 4 : 6),
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(teamName, style: TextStyle(
              fontSize: isCompact ? 11 : 13,
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
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, bool isCompact) {
    return Container(
      height: isCompact ? 36 : 44,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: isCompact ? 12 : 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight, fontSize: isCompact ? 11 : 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isCompact ? 8 : 10),
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
