import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_format_screen.dart';
import 'screens/player_details_screen.dart';
import 'screens/scoring_screen.dart';
import 'controllers/scoring_controller.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize scoring controller
  Get.put(ScoringController(), permanent: true);
  
  runApp(const PlayRallyApp());
}

class PlayRallyApp extends StatelessWidget {
  const PlayRallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PlayRally',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: Routes.splash,
      getPages: [
        GetPage(name: Routes.splash, page: () => const SplashScreen()),
        GetPage(name: Routes.home, page: () => const HomeScreen()),
        GetPage(name: Routes.gameFormat, page: () => const GameFormatScreen()),
        GetPage(name: Routes.playerDetails, page: () => const PlayerDetailsScreen()),
        GetPage(name: Routes.scoring, page: () => const ScoringScreen()),
      ],
    );
  }
}
