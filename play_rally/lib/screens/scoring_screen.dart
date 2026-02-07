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

class _ScoringScreenState extends State<ScoringScreen> with SingleTickerProviderStateMixin {
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
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.2),
                              color: Colors.white.withOpacity(0.95),
                              icon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.menu, color: Colors.black87, size: 24),
                              ),
                              onSelected: (value) {
                                if (value == 'score_logs') {
                                  controller.displayScoreLogs.value = true;
                                } else if (value == 'exit') {
                                  Get.offAllNamed(Routes.home);
                                } else if (value == 'mqtt') {
                                  controller.toggleMqtt();
                                } else if (value == 'qr') {
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
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: controller.mqttConnected.value 
                                              ? Colors.green.withOpacity(0.1) 
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          controller.mqttConnected.value ? Icons.cloud_done : Icons.cloud_off,
                                          color: controller.mqttConnected.value ? Colors.green : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        controller.mqttConnected.value ? 'Ticker Connected' : 'Connect Ticker',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )),
                                ),
                                PopupMenuItem(
                                  value: 'qr',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.qr_code, color: Colors.blueAccent, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Show Ticker QR', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'score_logs',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.history, color: Colors.orange, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Score Logs', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'exit',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Exit Match', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
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
              
              // Undo Button
              _buildUndoButton(controller),

              // Score Logs overlay
              const ScoreLogs(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUndoButton(ScoringController controller) {
    return Positioned(
      bottom: 30,
      right: 20, // Moved to right
      child: ClipRRect( // Clip for blur effect if we added BackdropFilter, keeping it simple for now
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.undo(),
            child: Container(
              width: 60, // Square shape
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25), // Glassy semi-transparent white
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5), // Glass border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.undo, color: Colors.black87, size: 28), // Dark icon for contrast
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreTable(ScoringController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reduced size back to original compact dimensions
        double tableWidth = MediaQuery.of(context).size.width * 0.25;
        tableWidth = tableWidth.clamp(150.0, 250.0);
        
        return Container(
          width: tableWidth,
          padding: const EdgeInsets.all(8), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: const FlexColumnWidth(2.5),
              for (int i = 1; i <= controller.numberOfSets.value; i++)
                i: const FlexColumnWidth(1),
            },
            children: [
              // Red team row
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6), // Reduced vertical padding
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, // Slightly smaller dot
                          height: 8, 
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFE53935).withOpacity(0.4), blurRadius: 4, offset:const Offset(0, 1))
                            ]
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Red', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                  ),
                  ...List.generate(controller.numberOfSets.value, (i) {
                    String scoreText = '';
                    bool isCurrent = false;
                    
                    if (i < controller.setScoresHistory.length) {
                      scoreText = '${controller.setScoresHistory[i]['red']}';
                    } else if (i == controller.currentSet.value - 1) {
                      scoreText = '${controller.redTeamScore.value}';
                      isCurrent = true;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        scoreText, 
                        textAlign: TextAlign.center, 
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                          color: isCurrent ? Colors.black87 : Colors.black54
                        )
                      ),
                    );
                  }),
                ],
              ),
              
              // Blue team row
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, 
                        height: 8, 
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.4), blurRadius: 4, offset:const Offset(0, 1))
                          ]
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Blue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                    ],
                  ),
                ),
                ...List.generate(controller.numberOfSets.value, (i) {
                  String scoreText = '';
                  bool isCurrent = false;
                  
                  if (i < controller.setScoresHistory.length) {
                    scoreText = '${controller.setScoresHistory[i]['blue']}';
                  } else if (i == controller.currentSet.value - 1) {
                    scoreText = '${controller.blueTeamScore.value}';
                    isCurrent = true;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      scoreText, 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? Colors.black87 : Colors.black54
                      )
                    ),
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
    // Use gradients matching the court
    Gradient leftGradient = swapped 
        ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF5E9EF7), Color(0xFF1976D2)])
        : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF75E5E), Color(0xFFE53935)]);
        
    Gradient rightGradient = swapped 
        ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF75E5E), Color(0xFFE53935)])
        : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF5E9EF7), Color(0xFF1976D2)]);

    int leftScore = swapped ? controller.blueTeamScore.value : controller.redTeamScore.value;
    int rightScore = swapped ? controller.redTeamScore.value : controller.blueTeamScore.value;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Slightly larger padding
          decoration: BoxDecoration(
            gradient: leftGradient,
            borderRadius: BorderRadius.circular(12), // Match glassy rounded look
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (swapped ? const Color(0xFF2196F3) : const Color(0xFFE53935)).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text('$leftScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('-', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black54)), // More subtle dash
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: rightGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (swapped ? const Color(0xFFE53935) : const Color(0xFF2196F3)).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text('$rightScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  // ... (build method remains mostly same, but we will inject the overlay logic inside _buildCourtHalf or wrapper)

  // ...

  Widget _buildCourtHalf(ScoringController controller, int side, Color color, String teamName, bool swapped) {
    bool isLeft = side == 0;
    
    // Get player positions for this side
    String topPos = isLeft ? 'tl' : 'tr';
    String bottomPos = isLeft ? 'bl' : 'br';
    
    // Access playerStats.value DIRECTLY for Obx reactivity
    var stats = controller.playerStats.value;
    String topPlayer = stats[topPos]?['name'] ?? '';
    String bottomPlayer = stats[bottomPos]?['name'] ?? '';
    
    // Use default names if empty ONLY for Doubles
    if (controller.isDoubles) {
      if (topPlayer.isEmpty) topPlayer = isLeft ? 'Red 1' : 'Blue 1';
      if (bottomPlayer.isEmpty) bottomPlayer = isLeft ? 'Red 2' : 'Blue 2';
    }
    
    bool topServing = stats[topPos]?['server'] == true;
    bool bottomServing = stats[bottomPos]?['server'] == true;

    // Define gradients based on the base color passed (trying to match the glassy look)
    bool isRedTeam = color.value == 0xFFE53935; 
    
    Gradient courtGradient = isRedTeam
        ? const LinearGradient(
            begin: Alignment.topCenter, // Scanned image shows top-down or slight diagonal
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF75E5E), Color(0xFFE53935)], // Smoother, vibrant red
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5E9EF7), Color(0xFF1976D2)], // Smoother, vibrant blue
          );

    return Stack(
      children: [
        // Court area with scoring tap
        GestureDetector(
          onTap: () {
            if (!controller.serverChosen.value) {
              Get.snackbar(
                'Select Server',
                'Please select a server to start the match',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                margin: const EdgeInsets.all(20),
                borderRadius: 20,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.touch_app, color: Colors.white),
              );
            } else {
              controller.scorePoint(side);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: courtGradient,
              borderRadius: BorderRadius.only(
                topLeft: isLeft ? const Radius.circular(30) : Radius.zero, 
                bottomLeft: isLeft ? const Radius.circular(30) : Radius.zero,
                topRight: isLeft ? Radius.zero : const Radius.circular(30),
                bottomRight: isLeft ? Radius.zero : const Radius.circular(30),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2, 
              ),
              boxShadow: [
                 BoxShadow(
                  color: color.withOpacity(0.4), 
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(height: 2, color: Colors.white.withOpacity(0.3)), 
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
                            Text(topPlayer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                            if (topServing) const SizedBox(width: 24),
                          ],
                        ),
                      ),
                    ),
                    // Bottom player
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bottomServing) _buildServeBall(),
                            Text(bottomPlayer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                            if (bottomServing) const SizedBox(width: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // LOCKED OVERLAY
                if (!controller.serverChosen.value)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), // Dim effect
                        borderRadius: BorderRadius.only(
                          topLeft: isLeft ? const Radius.circular(28) : Radius.zero,
                          bottomLeft: isLeft ? const Radius.circular(28) : Radius.zero,
                          topRight: isLeft ? Radius.zero : const Radius.circular(28),
                          bottomRight: isLeft ? Radius.zero : const Radius.circular(28),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.8), size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Select Server First",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // TAP TO SCORE INDICATOR
                // Show only when server is chosen AND match hasn't started (score 0-0)
                if (controller.serverChosen.value && 
                    controller.redTeamScore.value == 0 && 
                    controller.blueTeamScore.value == 0)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2), // Subtle dark pill
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 16, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 8),
                            Text(
                              "Tap to Score",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                borderRadius: BorderRadius.circular(20), 
                elevation: 4,
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    controller.swapTeamPlayers(side);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.swap_vert, color: isRedTeam ? const Color(0xFFE53935) : const Color(0xFF2196F3), size: 24),
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
    const double maxDrag = 40.0;
    
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Obx(() {
          bool matchStarted = controller.redTeamScore.value > 0 || controller.blueTeamScore.value > 0;
          int servingTeam = controller.servingTeam;
          bool hasSelection = servingTeam >= 0;

          return GestureDetector(
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
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
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            hasSelection ? controller.getCurrentScore() : 'Swipe to\nServer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: hasSelection ? 24 : 14, // Larger font for score
                              fontWeight: FontWeight.bold,
                              color: hasSelection 
                                  ? (servingTeam == 0 ? const Color(0xFFE53935) : const Color(0xFF2196F3))
                                  : Colors.blueAccent,
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
          );
        }), // End Obx
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
    String winnerName = controller.winner.value; // "Red" or "Blue"
    bool isRed = winnerName == 'Red';
    Color teamColor = isRed ? const Color(0xFFE53935) : const Color(0xFF2196F3);
    Gradient bgGradient = isRed
        ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF0F0), Color(0xFFFFCDD2)])
        : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: teamColor.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              BoxShadow(color: teamColor.withOpacity(0.3), blurRadius: 40, spreadRadius: -10),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy Icon with glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: teamColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 5),
                    ],
                  ),
                  child: Icon(Icons.emoji_events_rounded, size: 50, color: teamColor), // Reduced size slightly
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'MATCH COMPLETE',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Team $winnerName Wins!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.w900, 
                    color: teamColor,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Final Score: ${controller.redTeamSetsWon.value} - ${controller.blueTeamSetsWon.value} (Sets)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    // View Summary Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.back(); // Close dialog
                            controller.displayScoreLogs.value = true;
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: Text(
                                'View Summary',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Start New Match Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.resetMatch();
                            Get.offAllNamed(Routes.home);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [teamColor, teamColor.withOpacity(0.8)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: teamColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'New Match',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
