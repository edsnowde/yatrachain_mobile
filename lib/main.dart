import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yatrachain/theme.dart';
import 'package:yatrachain/providers/app_provider.dart';
import 'package:yatrachain/screens/splash_screen.dart';
import 'package:yatrachain/firebase_options.dart';
//import 'package:yatrachain/services/notification_service.dart';
//import 'package:yatrachain/services/gemini_ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  //await NotificationService.initialize();
  //await GeminiAIService.initialize();

  runApp(const YatraChainApp());
}

class YatraChainApp extends StatelessWidget {
  const YatraChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'YatraChain',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
