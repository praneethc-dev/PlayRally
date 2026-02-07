import 'dart:convert';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../MQTT/mqtt_service.dart';

/// Pickleball Scoring Controller
/// Proper rules: server on right, swap on score, side out to opponent second server
class ScoringController extends GetxController {
  // Game configuration
  var gameType = 'Doubles'.obs;
  var numberOfSets = 3.obs;
  var playTo = 11.obs;
  final int winBy = 2;

  // Match state
  var currentSet = 1.obs;
  var matchEnded = false.obs;
  var winner = ''.obs;
  
  // Set winner announcement
  var showSetWinner = false.obs;
  var setWinner = ''.obs;
  
  // Server selection state
  var serverChosen = false.obs;
  
  // Courts swapped state - when true, red court is on right, blue on left
  var courtsSwapped = false.obs;

  // Scores
  var redTeamScore = 0.obs;
  var blueTeamScore = 0.obs;
  var redTeamSetsWon = 0.obs;
  var blueTeamSetsWon = 0.obs;

  // Server tracking: 1 = first server, 2 = second server
  var serverScore = 2.obs;
  
  // Set scores history
  var setScoresHistory = <Map<String, int>>[].obs;
  
  // Player positions - tl/bl = left side, tr/br = right side
  // Each player has: team (0=Red, 1=Blue), name, server flag
  var playerStats = <String, Map<String, dynamic>>{
    'tl': {'team': 0, 'name': '', 'server': false},
    'bl': {'team': 0, 'name': '', 'server': false},
    'tr': {'team': 1, 'name': '', 'server': false},
    'br': {'team': 1, 'name': '', 'server': false},
  }.obs;

  // Score logs for tracking rally history
  var scoreLogs = <String, dynamic>{
    "start": <String>['Start Score'],
    "end": <String>['End Score'],
    "result": <String>['Result'],
    "servers": <String>['Server'],
    "setIndex": <int>[-1], // Header row has no set index
  }.obs;
  
  var displayScoreLogs = false.obs;

  // Animation states
  var showRallyAnimation = false.obs;
  var lastScoringTeam = ''.obs;

  // MQTT for real-time broadcasting
  final MqttService _mqttService = MqttService();
  String _matchUuid = '';
  var mqttConnected = false.obs;

  // Previous states for undo
  List<Map<String, dynamic>> prevMatchStats = [];
  List<Map<String, dynamic>> prevPlayerStats = [];

  bool get isDoubles => gameType.value == 'Doubles';

  // Get serving team based on who has server flag
  int get servingTeam {
    for (var pos in playerStats.keys) {
      if (playerStats[pos]!['server'] == true) {
        return playerStats[pos]!['team'] as int;
      }
    }
    return -1;
  }

  void setGameFormat({
    required String gameType,
    required int numberOfSets,
    required int playTo,
  }) {
    this.gameType.value = gameType;
    this.numberOfSets.value = numberOfSets;
    this.playTo.value = playTo;
  }

  void setPlayers({
    required String redPlayer1,
    String? redPlayer2,
    required String bluePlayer1,
    String? bluePlayer2,
  }) {
    if (gameType.value == 'Singles') {
      // Singles: Red starts at Bottom-Left (bl), Blue at Top-Right (tr)
      playerStats['tl']!['name'] = '';
      playerStats['bl']!['name'] = redPlayer1;
      playerStats['tr']!['name'] = bluePlayer1;
      playerStats['br']!['name'] = '';
    } else {
      // Doubles: Red team on left (tl, bl), Blue team on right (tr, br)
      playerStats['tl']!['name'] = redPlayer1;
      playerStats['bl']!['name'] = redPlayer2 ?? '';
      playerStats['tr']!['name'] = bluePlayer1;
      playerStats['br']!['name'] = bluePlayer2 ?? '';
    }
    
    // Reset all servers
    for (var pos in playerStats.keys) {
      playerStats[pos]!['server'] = false;
    }
    
    serverChosen.value = false;
    courtsSwapped.value = false;
    playerStats.refresh();
  }

  /// Swap top and bottom players within a team (side: 0 = left, 1 = right)
  void swapTeamPlayers(int side) {
    print('=== SWAP CALLED for side $side ===');
    
    // Access the underlying map value directly
    var stats = playerStats.value;
    
    print('BEFORE: tl=${stats['tl']?['name']}, bl=${stats['bl']?['name']}');
    print('BEFORE: tr=${stats['tr']?['name']}, br=${stats['br']?['name']}');
    
    if (side == 0) {
      // Swap left team (tl <-> bl)
      final tempTop = Map<String, dynamic>.from(stats['tl']!);
      stats['tl'] = Map<String, dynamic>.from(stats['bl']!);
      stats['bl'] = tempTop;
    } else {
      // Swap right team (tr <-> br)
      final tempTop = Map<String, dynamic>.from(stats['tr']!);
      stats['tr'] = Map<String, dynamic>.from(stats['br']!);
      stats['br'] = tempTop;
    }
    
    print('AFTER: tl=${stats['tl']?['name']}, bl=${stats['bl']?['name']}');
    print('AFTER: tr=${stats['tr']?['name']}, br=${stats['br']?['name']}');
    
    // Trigger UI update
    playerStats.refresh();
    print('=== REFRESH CALLED ===');
  }

  /// Choose serving team: 0 = left side, 1 = right side
  /// Serving position: left court = bottom (bl), right court = top (tr)
  /// This is because when facing opponent, server is on right-hand side
  void chooseServer(int team) {
    // Clear all server flags first
    for (var pos in playerStats.keys) {
      playerStats[pos]!['server'] = false;
    }
    
    // Find the serving position for the chosen team
    // Left court server = bl (bottom), Right court server = tr (top)
    String serverPos = '';
    
    // Check which side the selected team is on
    bool teamOnLeft = playerStats['tl']!['team'] == team || playerStats['bl']!['team'] == team;
    
    if (teamOnLeft) {
      // Left court: bottom player serves (bl)
      serverPos = 'bl';
    } else {
      // Right court: top player serves (tr)
      serverPos = 'tr';
    }
    
    playerStats[serverPos]!['server'] = true;
    
    serverScore.value = 2;  // Start at second server (0-0-2)
    serverChosen.value = true;
    playerStats.refresh();
  }

  /// Toggle server number manually (1 <-> 2)
  void toggleServerNumber() {
    if (!serverChosen.value || gameType.value == 'Singles') return;
    
    serverScore.value = serverScore.value == 1 ? 2 : 1;
    // We might want to refresh playerStats just to ensure UI updates if it depends on this
    playerStats.refresh(); 
  }

  /// Score point by clicking on a side (0 = left, 1 = right)
  void scorePoint(int side) {
    if (matchEnded.value || !serverChosen.value) return;

    _saveState();
    
    // Capture start score before any changes
    String startScore = getCurrentScore();
    String serverName = getServerNameForLog();
    
    // Find server position and related positions
    String serverPos = playerStats.keys.firstWhere((k) => playerStats[k]!['server'] == true);
    String teammatePos = '';
    bool won = false;
    bool serverOnLeft = (serverPos == 'tl' || serverPos == 'bl');
    
    // Determine teammate position
    if (serverPos == 'tl') { teammatePos = 'bl'; won = side == 0; }
    else if (serverPos == 'bl') { teammatePos = 'tl'; won = side == 0; }
    else if (serverPos == 'tr') { teammatePos = 'br'; won = side == 1; }
    else if (serverPos == 'br') { teammatePos = 'tr'; won = side == 1; }
    
    int serverTeamIndex = playerStats[serverPos]!['team'] as int;
    String result = '';

    if (won) {
      // Serving team wins rally - SWAP POSITIONS and score
      var temp = Map<String, dynamic>.from(playerStats[serverPos]!);
      playerStats[serverPos] = Map<String, dynamic>.from(playerStats[teammatePos]!);
      playerStats[teammatePos] = temp;
      
      // Add point to serving team
      if (serverTeamIndex == 0) {
        redTeamScore.value++;
        lastScoringTeam.value = 'Red';
      } else {
        blueTeamScore.value++;
        lastScoringTeam.value = 'Blue';
      }
      
      result = 'Point';
      _triggerAnimation();
    } else {
      // Serving team loses rally
      if (gameType.value == 'Singles') {
        // SINGLES: Side Out Logic
        playerStats[serverPos]!['server'] = false;
        
        int opponentTeamNum = (serverTeamIndex == 0) ? 1 : 0;
        int opponentScore = (opponentTeamNum == 0) ? redTeamScore.value : blueTeamScore.value;
        bool shouldBeOnRight = (opponentScore % 2 == 0);
        
        String correctPos = '';
        String wrongPos = '';
        
        bool isOpponentOnLeft;
        if (!courtsSwapped.value) {
          isOpponentOnLeft = (opponentTeamNum == 0);
        } else {
          isOpponentOnLeft = (opponentTeamNum == 1);
        }
        
        if (isOpponentOnLeft) {
          correctPos = shouldBeOnRight ? 'bl' : 'tl';
          wrongPos = shouldBeOnRight ? 'tl' : 'bl';
        } else {
          correctPos = shouldBeOnRight ? 'tr' : 'br';
          wrongPos = shouldBeOnRight ? 'br' : 'tr';
        }
        
        bool playerAtCorrect = (playerStats[correctPos]!['name'] as String).isNotEmpty;
        
        if (!playerAtCorrect) {
          var temp = Map<String, dynamic>.from(playerStats[correctPos]!);
          playerStats[correctPos] = Map<String, dynamic>.from(playerStats[wrongPos]!);
          playerStats[wrongPos] = temp;
        }
        
        playerStats[correctPos]!['server'] = true;
        serverScore.value = 1; 
        
        result = 'Side-out';
        
      } else {
        // DOUBLES Logic
        if (serverScore.value == 1) {
          // First server lost - switch to teammate (Second Serve)
          print('DEBUG: First Server Lost. Switching to Server 2.');
          playerStats[serverPos]!['server'] = false;
          playerStats[teammatePos]!['server'] = true;
          
          serverScore.value = 2; // Immediate update
          
          result = 'Second Serve';
        } else {
          // Second server lost - SIDE OUT
          print('DEBUG: Second Server Lost. Side Out.');
          String opponentServePos = serverOnLeft ? 'tr' : 'bl';
          playerStats[serverPos]!['server'] = false;
          playerStats[opponentServePos]!['server'] = true;
          
          serverScore.value = 1; // Immediate update
          
          result = 'Side-out';
        }
      }
    }
    
    // Log the score event
    String endScore = getCurrentScore();
    logScore(startScore, endScore, serverName, result);
    print('DEBUG: Score Update. Start: $startScore, End: $endScore');
    
    // Publish to MQTT
    publishScore(eventType: won ? 1 : 0);
    
    serverScore.refresh(); // Force refresh of server score
    playerStats.refresh(); // Update player stats (positions/server flag)
    _checkSetWin();
  }

  void _triggerAnimation() {
    showRallyAnimation.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      showRallyAnimation.value = false;
    });
  }

  void _checkSetWin() {
    int redScore = redTeamScore.value;
    int blueScore = blueTeamScore.value;
    int target = playTo.value;

    bool redWins = redScore >= target && (redScore - blueScore) >= winBy;
    bool blueWins = blueScore >= target && (blueScore - redScore) >= winBy;

    if (redWins) {
      _setWon('Red');
    } else if (blueWins) {
      _setWon('Blue');
    }
  }

  void _setWon(String team) {
    setScoresHistory.add({
      'red': redTeamScore.value,
      'blue': blueTeamScore.value,
    });
    
    if (team == 'Red') {
      redTeamSetsWon.value++;
    } else {
      blueTeamSetsWon.value++;
    }
    setWinner.value = team;

    int setsToWin = (numberOfSets.value / 2).ceil();

    if (redTeamSetsWon.value >= setsToWin) {
      _matchWon('Red');
    } else if (blueTeamSetsWon.value >= setsToWin) {
      _matchWon('Blue');
    } else {
      showSetWinner.value = true;
    }
  }

  void continueToNextSet() {
    showSetWinner.value = false;
    setWinner.value = '';
    _startNextSet();
  }

  void _startNextSet() {
    currentSet.value++;
    redTeamScore.value = 0;
    blueTeamScore.value = 0;
    serverScore.value = 2;

    // SWAP COURTS - swap all player positions
    _swapCourts();

    // Reset server selection
    serverChosen.value = false;
    for (var pos in playerStats.keys) {
      playerStats[pos]!['server'] = false;
    }
    playerStats.refresh();
  }

  void _swapCourts() {
    courtsSwapped.value = !courtsSwapped.value;
    
    // Swap player positions: tl<->tr, bl<->br
    // Team indices stay with the players (Red=0, Blue=1)
    var tempTL = Map<String, dynamic>.from(playerStats['tl']!);
    var tempBL = Map<String, dynamic>.from(playerStats['bl']!);
    
    playerStats['tl'] = Map<String, dynamic>.from(playerStats['tr']!);
    playerStats['bl'] = Map<String, dynamic>.from(playerStats['br']!);
    playerStats['tr'] = tempTL;
    playerStats['br'] = tempBL;
    
    // NOTE: Team indices stay with players - DO NOT reset them
    // After swap: Blue players (team 1) are now at tl/bl
    //             Red players (team 0) are now at tr/br
    
    playerStats.refresh();
  }

  void _matchWon(String teamName) {
    matchEnded.value = true;
    winner.value = teamName;
  }

  void _saveState() {
    prevMatchStats.add({
      'redTeamScore': redTeamScore.value,
      'blueTeamScore': blueTeamScore.value,
      'serverScore': serverScore.value,
      'currentSet': currentSet.value,
    });
    prevPlayerStats.add(jsonDecode(jsonEncode(playerStats)));
  }

  void undo() {
    if (prevMatchStats.isEmpty) return;

    var lastMatch = prevMatchStats.removeLast();
    var lastPlayers = prevPlayerStats.removeLast();

    redTeamScore.value = lastMatch['redTeamScore'];
    blueTeamScore.value = lastMatch['blueTeamScore'];
    serverScore.value = lastMatch['serverScore'];
    currentSet.value = lastMatch['currentSet'];
    
    playerStats.assignAll(Map<String, Map<String, dynamic>>.from(
      (lastPlayers as Map).map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v)))
    ));

    // Remove last log entry
    if ((scoreLogs['start'] as List).length > 1) {
      (scoreLogs['start'] as List).removeLast();
      (scoreLogs['end'] as List).removeLast();
      (scoreLogs['servers'] as List).removeLast();
      (scoreLogs['result'] as List).removeLast();
      (scoreLogs['setIndex'] as List).removeLast();
      scoreLogs.refresh();
    }
  }

  void resetMatch() {
    redTeamScore.value = 0;
    blueTeamScore.value = 0;
    redTeamSetsWon.value = 0;
    blueTeamSetsWon.value = 0;
    currentSet.value = 1;
    serverScore.value = 2;
    matchEnded.value = false;
    winner.value = '';
    serverChosen.value = false;
    courtsSwapped.value = false;
    showSetWinner.value = false;
    setWinner.value = '';
    setScoresHistory.clear();
    prevMatchStats.clear();
    prevPlayerStats.clear();
    
    for (var pos in playerStats.keys) {
      playerStats[pos]!['server'] = false;
    }
    playerStats.refresh();
  }

  /// Get the current score string: serving_team_score-opponent_score-server#
  /// Get the current score string: serving_team_score-opponent_score-server#
  String getCurrentScore() {
    if (!serverChosen.value) {
      return gameType.value == 'Singles' ? '0-0' : '0-0-2';
    }
    
    int servTeam = servingTeam;
    String baseScore;
    if (servTeam == 0) {
      baseScore = '${redTeamScore.value}-${blueTeamScore.value}';
    } else {
      baseScore = '${blueTeamScore.value}-${redTeamScore.value}';
    }

    if (gameType.value == 'Singles') {
      return baseScore;
    } else {
      return '$baseScore-${serverScore.value}';
    }
  }
  
  /// Get player name at position (accesses .value for reactivity)
  String getPlayerName(String pos) {
    var stats = playerStats.value;
    return stats[pos]?['name'] ?? '';
  }
  
  /// Check if player at position is serving (accesses .value for reactivity)
  bool isServing(String pos) {
    var stats = playerStats.value;
    return stats[pos]?['server'] == true;
  }
  
  /// Log a score event
  void logScore(String startScore, String endScore, String serverName, String result) {
    (scoreLogs['start'] as List<String>).add(startScore);
    (scoreLogs['end'] as List<String>).add(endScore);
    (scoreLogs['servers'] as List<String>).add(serverName);
    (scoreLogs['result'] as List<String>).add(result);
    (scoreLogs['setIndex'] as List<int>).add(currentSet.value - 1);
    scoreLogs.refresh();
  }
  
  /// Reset score logs for new match
  void resetScoreLogs() {
    scoreLogs['start'] = <String>['Start Score'];
    scoreLogs['end'] = <String>['End Score'];
    scoreLogs['result'] = <String>['Result'];
    scoreLogs['servers'] = <String>['Server'];
    scoreLogs['setIndex'] = <int>[-1];
    scoreLogs.refresh();
  }
  
  /// Get server name for logging
  String getServerNameForLog() {
    String serverPos = playerStats.keys.firstWhere(
      (k) => playerStats[k]!['server'] == true,
      orElse: () => '',
    );
    if (serverPos.isEmpty) return 'Unknown';
    String name = playerStats[serverPos]?['name'] ?? '';
    if (name.isEmpty) {
      return serverPos == 'tl' || serverPos == 'bl' ? 'Red' : 'Blue';
    }
    // Return first initial + last name like PTMS
    List<String> parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Player';
    if (parts.length == 1) return parts[0];
    return '${parts[0][0]}.${parts[1]}';
  }
  
  // ==================== MQTT METHODS ====================
  
  /// Initialize match with unique UUID for MQTT topic
  void initMatch() {
    _matchUuid = const Uuid().v4();
    print('Match initialized with UUID: $_matchUuid');
  }
  
  /// Connect to MQTT broker
  Future<void> connectMqtt() async {
    await _mqttService.connect();
    mqttConnected.value = _mqttService.isConnected;
  }
  
  /// Disconnect from MQTT broker
  void disconnectMqtt() {
    _mqttService.disconnect();
    mqttConnected.value = false;
  }
  
  /// Toggle MQTT connection
  Future<void> toggleMqtt() async {
    if (mqttConnected.value) {
      _mqttService.setEnabled(false);
      disconnectMqtt();
    } else {
      _mqttService.setEnabled(true);
      await connectMqtt();
    }
  }
  
  /// Check if MQTT is connected
  bool get isMqttConnected => _mqttService.isConnected;
  
  /// Get current match UUID
  String get matchUuid => _matchUuid;
  
  /// Publish current score to MQTT
  void publishScore({int eventType = 1}) {
    if (_matchUuid.isEmpty) {
      initMatch();
    }
    
    try {
      // Build player list for each team
      List<Map<String, dynamic>> redPlayers = [];
      List<Map<String, dynamic>> bluePlayers = [];
      
      for (var pos in playerStats.keys) {
        var player = playerStats[pos]!;
        var playerData = {
          'name': player['name'] ?? '',
          'isServing': player['server'] == true,
        };
        if (player['team'] == 0) {
          redPlayers.add(playerData);
        } else {
          bluePlayers.add(playerData);
        }
      }
      
      // Build payload
      final payload = {
        'matchId': _matchUuid,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'status': matchEnded.value ? 2 : 1,
        'matchType': numberOfSets.value,
        'gameType': gameType.value,
        'totalSets': numberOfSets.value,
        'currentSet': currentSet.value,
        'playTo': playTo.value,
        'teamA': {
          'teamName': 'Red',
          'score': redTeamScore.value,
          'setsWon': redTeamSetsWon.value,
          'players': redPlayers,
        },
        'teamB': {
          'teamName': 'Blue',
          'score': blueTeamScore.value,
          'setsWon': blueTeamSetsWon.value,
          'players': bluePlayers,
        },
        'serverScore': serverScore.value,
        'event': eventType,
        'winner': winner.value,
      };
      
      _mqttService.publish('sports/pickleball/match/$_matchUuid', payload);
    } catch (e) {
      print('Failed to publish MQTT: $e');
    }
  }
}
