import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scoring_controller.dart';
import '../utils/constants.dart';
import '../widgets/score_logs.dart';
import '../widgets/match_qr_code.dart';

/// Scoring Screen with court swap support
class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  double _sliderOffset = 0.0;
  bool _matchDialogShown = false;
  bool _setDialogShown = false;
  
  @override
  Widget build(BuildContext context) {
    final ScoringController controller = Get.find<ScoringController>();

    return Scaffold(
      backgroundColor: const Color(0xFFD4F1F9),
      body: SafeArea(
        child: Obx(() {
          if (controller.matchEnded.value && !_matchDialogShown) {
            _matchDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showWinnerDialog(context, controller);
            });
          }
          
          if (controller.showSetWinner.value && !_setDialogShown) {
            _setDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSetWinnerDialog(context, controller);
            });
          }
          
          if (!controller.showSetWinner.value) {
            _setDialogShown = false;
          }

          // Determine court colors based on swap state
          bool swapped = controller.courtsSwapped.value;
          Color leftColor = swapped ? const Color(0xFF2196F3) : const Color(0xFFE53935);
          Color rightColor = swapped ? const Color(0xFFE53935) : const Color(0xFF2196F3);
          String leftTeam = swapped ? 'Blue' : 'Red';
          String rightTeam = swapped ? 'Red' : 'Blue';

          return Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  
                  // Top section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left section - score table
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildScoreTable(controller),
                          ),
                        ),
                        // Center section - main score
                        _buildMainScore(controller, swapped),
                        // Right section - hamburger menu
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.menu, color: Colors.black87),
                              ),
                              onSelected: (value) {
                                if (value == 'score_logs') {
                                  controller.displayScoreLogs.value = true;
                                } else if (value == 'undo') {
                                  controller.undo();
                                } else if (value == 'reset') {
                                  controller.resetMatch();
                                } else if (value == 'mqtt') {
                                  controller.toggleMqtt();
                                } else if (value == 'qr') {
                                  // Initialise match UUID if empty before showing QR
                                  if (controller.matchUuid.isEmpty) {
                                    controller.initMatch();
                                  }
                                  Get.dialog(const MatchQrCode());
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'mqtt',
                                  child: Obx(() => Row(
                                    children: [
                                      Icon(
                                        controller.mqttConnected.value ? Icons.cloud_done : Icons.cloud_off,
                                        color: controller.mqttConnected.value ? Colors.green : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(controller.mqttConnected.value ? 'MQTT Connected' : 'Connect MQTT'),
                                    ],
                                  )),
                                ),
                                const PopupMenuItem(
                                  value: 'qr',
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code, color: Colors.black54),
                                      SizedBox(width: 12),
                                      Text('Show Ticker QR'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'score_logs',
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, color: Colors.black54),
                                      SizedBox(width: 12),
                                      Text('Score Logs'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'undo',
                                  child: Row(
                                    children: [
                                      Icon(Icons.undo, color: Colors.black54),
                                      SizedBox(width: 12),
                                      Text('Undo'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reset',
                                  child: Row(
                                    children: [
                                      Icon(Icons.refresh, color: Colors.black54),
                                      SizedBox(width: 12),
                                      Text('Reset Match'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Court
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(125, 0, 125, 30),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Court halves - wrapped in Obx to react to playerStats changes
                              Obx(() {
                                // Force dependency on playerStats by reading it
                                final _ = controller.playerStats.value;
                                return Row(
                                  children: [
                                    Expanded(child: _buildCourtHalf(controller, 0, leftColor, leftTeam, swapped)),
                                    Expanded(child: _buildCourtHalf(controller, 1, rightColor, rightTeam, swapped)),
                                  ],
                                );
                              }),
                              // Draggable Server slider
                              _buildDraggableServerSlider(controller, constraints),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              if (controller.showRallyAnimation.value)
                _buildRallyAnimation(controller),
              
              // Score Logs overlay
              const ScoreLogs(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScoreTable(ScoringController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive width based on screen size
        double tableWidth = MediaQuery.of(context).size.width * 0.25;
        tableWidth = tableWidth.clamp(150.0, 250.0);
        
        return Container(
          width: tableWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Table(
            columnWidths: {
              0: const FlexColumnWidth(2),
              for (int i = 1; i <= controller.numberOfSets.value; i++)
                i: const FlexColumnWidth(1),
            },
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            children: [
              // Red team row
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Red', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
                    ],
                  ),
                ),
                ...List.generate(controller.numberOfSets.value, (i) {
                  String scoreText = '';
                  if (i < controller.setScoresHistory.length) {
                    scoreText = '${controller.setScoresHistory[i]['red']}';
                  } else if (i == controller.currentSet.value - 1) {
                    scoreText = '${controller.redTeamScore.value}';
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(scoreText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  );
                }),
              ]),
              // Blue team row
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Blue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                    ],
                  ),
                ),
                ...List.generate(controller.numberOfSets.value, (i) {
                  String scoreText = '';
                  if (i < controller.setScoresHistory.length) {
                    scoreText = '${controller.setScoresHistory[i]['blue']}';
                  } else if (i == controller.currentSet.value - 1) {
                    scoreText = '${controller.blueTeamScore.value}';
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(scoreText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  );
                }),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainScore(ScoringController controller, bool swapped) {
    // Score boxes - left color shows left team's score
    Color leftColor = swapped ? const Color(0xFF2196F3) : const Color(0xFFE53935);
    Color rightColor = swapped ? const Color(0xFFE53935) : const Color(0xFF2196F3);
    int leftScore = swapped ? controller.blueTeamScore.value : controller.redTeamScore.value;
    int rightScore = swapped ? controller.redTeamScore.value : controller.blueTeamScore.value;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: leftColor, borderRadius: BorderRadius.circular(8)),
          child: Text('$leftScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('-', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: rightColor, borderRadius: BorderRadius.circular(8)),
          child: Text('$rightScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCourtHalf(ScoringController controller, int side, Color color, String teamName, bool swapped) {
    bool isLeft = side == 0;
    
    // Get player positions for this side
    String topPos = isLeft ? 'tl' : 'tr';
    String bottomPos = isLeft ? 'bl' : 'br';
    
    // Access playerStats.value DIRECTLY for Obx reactivity
    var stats = controller.playerStats.value;
    String topPlayer = stats[topPos]?['name'] ?? '';
    String bottomPlayer = stats[bottomPos]?['name'] ?? '';
    
    // Use default names if empty
    if (topPlayer.isEmpty) topPlayer = isLeft ? 'Red 1' : 'Blue 1';
    if (bottomPlayer.isEmpty) bottomPlayer = isLeft ? 'Red 2' : 'Blue 2';
    
    bool topServing = stats[topPos]?['server'] == true;
    bool bottomServing = stats[bottomPos]?['server'] == true;
    
    return Stack(
      children: [
        // Court area with scoring tap
        GestureDetector(
          onTap: () => controller.scorePoint(side),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: isLeft ? const Radius.circular(20) : Radius.zero,
                bottomLeft: isLeft ? const Radius.circular(20) : Radius.zero,
                topRight: isLeft ? Radius.zero : const Radius.circular(20),
                bottomRight: isLeft ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(height: 2, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
                Column(
                  children: [
                    // Top player
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (topServing) _buildServeBall(),
                            Text(topPlayer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                            if (topServing) const SizedBox(width: 24),
                          ],
                        ),
                      ),
                    ),
                    // Bottom player
                    if (controller.isDoubles)
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (bottomServing) _buildServeBall(),
                              Text(bottomPlayer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                              if (bottomServing) const SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Swap button - OUTSIDE the scoring GestureDetector
        if (controller.isDoubles && controller.redTeamScore.value == 0 && controller.blueTeamScore.value == 0)
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? 8 : null,
            right: isLeft ? null : 8,
            child: Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    controller.swapTeamPlayers(side);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.swap_vert, color: isLeft ? const Color(0xFFE53935) : const Color(0xFF2196F3), size: 24),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServeBall() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.yellow.shade600,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: const Icon(Icons.sports_tennis, size: 12, color: Colors.white),
    );
  }

  Widget _buildDraggableServerSlider(ScoringController controller, BoxConstraints constraints) {
    bool matchStarted = controller.redTeamScore.value > 0 || controller.blueTeamScore.value > 0;
    int servingTeam = controller.servingTeam;
    bool hasSelection = servingTeam >= 0;
    
    const double maxDrag = 40.0;
    
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onHorizontalDragUpdate: matchStarted ? null : (details) {
            setState(() {
              _sliderOffset = (_sliderOffset + details.delta.dx).clamp(-maxDrag, maxDrag);
              
              if (_sliderOffset < -15) {
                // Dragged left - choose left court's team
                controller.chooseServer(controller.courtsSwapped.value ? 1 : 0);
              } else if (_sliderOffset > 15) {
                // Dragged right - choose right court's team
                controller.chooseServer(controller.courtsSwapped.value ? 0 : 1);
              }
            });
          },
          onHorizontalDragEnd: matchStarted ? null : (details) {
            setState(() {
              if (_sliderOffset < -15) {
                controller.chooseServer(controller.courtsSwapped.value ? 1 : 0);
              } else if (_sliderOffset > 15) {
                controller.chooseServer(controller.courtsSwapped.value ? 0 : 1);
              }
              _sliderOffset = 0;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(_sliderOffset, 0, 0),
            width: 70,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left, size: 28, 
                  color: servingTeam == 0 ? const Color(0xFFE53935) : 
                         servingTeam == 1 ? const Color(0xFF2196F3) : Colors.grey.shade400),
                
                const SizedBox(height: 8),
                
                // Center text
                Expanded(
                  child: Center(
                    child: hasSelection && !matchStarted
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...(servingTeam == 0 ? 'RED' : 'BLUE').split('').map((letter) => 
                                Text(letter, style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: servingTeam == 0 ? const Color(0xFFE53935) : const Color(0xFF2196F3),
                                  height: 1.0,
                                )),
                              ),
                              const SizedBox(height: 2),
                              Text('Team', style: TextStyle(
                                fontSize: 8, fontWeight: FontWeight.w600,
                                color: servingTeam == 0 ? const Color(0xFFE53935) : const Color(0xFF2196F3),
                              )),
                              Text('Serving', style: TextStyle(
                                fontSize: 8, fontWeight: FontWeight.w600,
                                color: servingTeam == 0 ? const Color(0xFFE53935) : const Color(0xFF2196F3),
                              )),
                            ],
                          )
                        : RotatedBox(
                            quarterTurns: 3,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                matchStarted ? controller.getCurrentScore() : 'Choose Server',
                                style: TextStyle(
                                  fontSize: matchStarted ? 18 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: matchStarted 
                                      ? (servingTeam == 0 ? const Color(0xFFE53935) : const Color(0xFF2196F3))
                                      : Colors.grey.shade700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Icon(Icons.chevron_right, size: 28,
                  color: servingTeam == 1 ? const Color(0xFF2196F3) : 
                         servingTeam == 0 ? const Color(0xFFE53935) : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRallyAnimation(ScoringController controller) {
    final isRed = controller.lastScoringTeam.value == 'Red';
    final color = isRed ? const Color(0xFFE53935) : const Color(0xFF2196F3);
    return Container(
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Text('+1', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  void _showWinnerDialog(BuildContext context, ScoringController controller) {
    String winnerName = 'Team ${controller.winner.value}';
    Color winnerColor = controller.winner.value == 'Red' ? const Color(0xFFE53935) : const Color(0xFF2196F3);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [Icon(Icons.emoji_events, color: winnerColor, size: 28), const SizedBox(width: 10), const Text('Match Complete!')]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$winnerName Wins!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: winnerColor)),
          const SizedBox(height: 8),
          Text('Final: ${controller.redTeamSetsWon.value} - ${controller.blueTeamSetsWon.value}'),
        ]),
        actions: [TextButton(onPressed: () { controller.resetMatch(); Get.offAllNamed(Routes.home); }, child: Text('Home', style: TextStyle(color: AppColors.primary)))],
      ),
      barrierDismissible: false,
    );
  }

  void _showSetWinnerDialog(BuildContext context, ScoringController controller) {
    String winnerName = 'Team ${controller.setWinner.value}';
    Color winnerColor = controller.setWinner.value == 'Red' ? const Color(0xFFE53935) : const Color(0xFF2196F3);
    int setNumber = controller.currentSet.value;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.all(12),
        title: Row(
          children: [
            Icon(Icons.sports_tennis, color: winnerColor, size: 24),
            const SizedBox(width: 8),
            Flexible(child: Text('Set $setNumber Complete!', style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$winnerName Wins!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: winnerColor)),
            const SizedBox(height: 8),
            Text('Score: ${controller.redTeamScore.value} - ${controller.blueTeamScore.value}'),
            const SizedBox(height: 4),
            Text('Sets: ${controller.redTeamSetsWon.value} - ${controller.blueTeamSetsWon.value}', 
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 6),
                  const Text('Courts swap!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.continueToNextSet();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: winnerColor, borderRadius: BorderRadius.circular(8)),
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
