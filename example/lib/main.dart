import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:env_indicator/env_indicator.dart';

/// Global instance of [AppInfo] used to store environment information
late AppInfo appInfo;

/// The main entry point of the application.
///
/// Initializes environment settings and launches the Flutter app.
/// Loads environment variables from .env file and sets up the [AppInfo]
/// instance with environment name and colors.
Future<void> main() async {

  /// Load environment settings from .env file (required only if you want to maintain those values without changing source code per environment)
  await dotenv.load(fileName: '.env');
  final String? env = dotenv.env['ENV_NAME'];
  final String? dotColor = dotenv.env['ENV_DOT_COLOR'];
  final String? textColor = dotenv.env['ENV_TEXT_COLOR'];
  final String? height = dotenv.env['ENV_LABEL_HEIGHT'];

  /// Initialize the AppInfo
  appInfo = AppInfo();
  await appInfo.init(env, dotColor: dotColor, textColor: textColor, height: height);

  runApp(const MyApp());
}

/// Creates a Material app with a scaffold containing sample text and
/// the [EnvIndicator] widget that shows the current environment and the device details.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Relax!', style: TextStyle(fontSize: 36.0)),
                  Text(
                    'And, check your app detail.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),

            /// Locate EnvIndicator
            EnvIndicator(
              appInfo: appInfo,
            ),
          ],

        ),
      ),
    );
  }
}