import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:env_indicator/env_indicator.dart';

late AppInfo appInfo;

Future<void> main() async {

  /// load DEV environment settings from a file
  await dotenv.load(fileName: '.env');
  final String? env = dotenv.env['ENV_NAME']; // ex: 'DEV', 'QA', or 'PROD'
  final String? dotColor = dotenv.env['ENV_DOT_COLOR']; // RGB hex value ex: '115E12'
  final String? textColor = dotenv.env['ENV_TEXT_COLOR']; // RGB hex value ex: '050506'

  appInfo = AppInfo();
  await appInfo.init(env, dotColor: dotColor, textColor: textColor);
  runApp(const MyApp());
}

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
                  Text('And, check your app detail.', style: TextStyle(fontSize: 18.0)),
                ],
              ),
            ),
            EnvIndicator(appInfo: appInfo), // ← Environment Indicator rendered here
          ],
        ),
      ),
    );
  }
}