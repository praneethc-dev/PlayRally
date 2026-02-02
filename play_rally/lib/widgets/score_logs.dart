import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scoring_controller.dart';

class ScoreLogs extends StatelessWidget {
  const ScoreLogs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScoringController>();

    return Obx(
      () => controller.displayScoreLogs.value
          ? Stack(
              children: [
                // Blur background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // Centered ScoreLogs Card
                Align(
                  alignment: Alignment.center,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 400,
                        width: 600,
                        child: Column(
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Score Logs",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      controller.displayScoreLogs.value = false;
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.close, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: Text('Start', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                  Expanded(flex: 2, child: Text('Server', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                  Expanded(flex: 2, child: Text('Result', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                  Expanded(flex: 2, child: Text('End', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),

                            // Scrollable Log Entries
                            Expanded(
                              child: Obx(() {
                                final starts = controller.scoreLogs['start'] as List<String>;
                                final ends = controller.scoreLogs['end'] as List<String>;
                                final servers = controller.scoreLogs['servers'] as List<String>;
                                final results = controller.scoreLogs['result'] as List<String>;
                                final setIndices = controller.scoreLogs['setIndex'] as List<int>;
                                
                                if (starts.length <= 1) {
                                  return const Center(
                                    child: Text('No score logs yet', style: TextStyle(color: Colors.grey)),
                                  );
                                }
                                
                                return ListView.builder(
                                  itemCount: starts.length - 1, // Skip header row
                                  itemBuilder: (context, index) {
                                    final i = index + 1; // Skip header
                                    
                                    // Check if this is a new game/set
                                    bool isNewGame = i > 1 && setIndices[i] != setIndices[i - 1];
                                    
                                    return Column(
                                      children: [
                                        if (isNewGame) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: Text(
                                                  'Game ${setIndices[i] + 1}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                ),
                                              ),
                                              Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 2, child: Text(starts[i], textAlign: TextAlign.center)),
                                              Expanded(flex: 2, child: Text(servers[i], textAlign: TextAlign.center)),
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: results[i] == 'Point'
                                                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                                                        : results[i] == 'Side-out'
                                                            ? const Color(0xFFE53935).withOpacity(0.2)
                                                            : const Color(0xFFFFC107).withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    results[i],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: results[i] == 'Point'
                                                          ? const Color(0xFF4CAF50)
                                                          : results[i] == 'Side-out'
                                                              ? const Color(0xFFE53935)
                                                              : const Color(0xFFFFC107),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(flex: 2, child: Text(ends[i], textAlign: TextAlign.center)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
