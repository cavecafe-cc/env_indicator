import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:env_indicator/env_indicator.dart';

void main() {
  group('EnvIndicator', () {
    testWidgets('should not show indicator in production', (
      WidgetTester tester,
    ) async {
      final appInfo = AppInfo()..env = AppInfo.defaultEnv;

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(children: [EnvIndicator(appInfo: appInfo)]),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('should show indicator in non-production', (
      WidgetTester tester,
    ) async {
      final appInfo = AppInfo()..env = 'DEV';

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(children: [EnvIndicator(appInfo: appInfo)]),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('DEV'), findsOneWidget);
    });
  });
}
