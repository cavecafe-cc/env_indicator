import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// [AppInfo] Provides application and device information for the EnvIndicator.
class AppInfo {
  /// default values
  static const String defaultEnv = 'PROD';
  static const String defaultColorHex = '000000';
  static const String defaultHeight = '90';

  /// [defaultColor] is not only set as transparent but also DO NOT show the [SizedBox] itself in the [build] function
  static const Color defaultColor = Colors.transparent;

  String env = defaultEnv;
  Color envDotColor = defaultColor;
  Color envTextColor = defaultColor;
  double envHeight = double.parse(defaultHeight);

  String version = '0.0.0';
  String build = '0';
  String package = '';
  String osVersion = ' - ';
  String deviceModel = ' - ';
  String deviceDetail = ' - ';

  /// Initialize AppInfo instance with environment settings.
  /// [env] Environment name ('DEV', 'QA', or 'PROD')
  /// [dotColor] RGB hex value for the indicator dot color (ex: '115E12')
  /// [textColor] RGB hex value for the text color (ex: '050506')
  Future<void> init(
    String? env, {
    String? dotColor = defaultColorHex,
    String? textColor = defaultColorHex,
    String? height = defaultHeight,
  }) async {
    env ??= defaultEnv;
    dotColor ??= defaultColorHex;
    textColor ??= defaultColorHex;
    height ??= defaultHeight;

    this.env = env.toUpperCase();
    envDotColor = _hexToColor(dotColor);
    envTextColor = _hexToColor(textColor);
    envHeight = double.parse(height);

    final packageInfo = await PackageInfo.fromPlatform();
    package = packageInfo.packageName;
    version = packageInfo.version;
    build = packageInfo.buildNumber;
    deviceModel = await _getDeviceModel();
    osVersion = await _getOsVersionInfo();
    deviceDetail = Platform.operatingSystemVersion;
  }

  /// Returns true if the current environment is set to production (PROD).
  /// This is used to determine whether the environment indicator should be displayed or not.
  bool isProduction() => (env == defaultEnv);

  Color _hexToColor(String hexString) {
    if (hexString == defaultColorHex) return Colors.transparent;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<String> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return "${androidInfo.manufacturer} ${androidInfo.model}"; // ex: Google Pixel 7
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine; // ex: iPhone15,3
    } else {
      return " ? ";
    }
  }

  Future<String> _getOsVersionInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return "Android API Level ${androidInfo.version.sdkInt} (${androidInfo.version.release})"; // ex: "Android API Level 34 (14)"
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return "iOS ${iosInfo.systemVersion}"; // ex: "iOS 17.5.1"
    } else {
      return " ? ";
    }
  }
}

/// A widget that displays the current app environment
/// (DEV, QA, or PROD) as a small colored indicator on screen.
///
/// The indicator is shown as a circular dot in the top-right corner
/// of the screen. It displays the build number and environment name
/// inside the dot, along with additional app/device details in a
/// rotated text panel below.
///
/// This widget is only visible in non-production environments.
/// In production (PROD) builds, it renders as an empty [SizedBox].
class EnvIndicator extends StatelessWidget {
  final AppInfo appInfo;

  /// Creates a new [EnvIndicator] widget.
  const EnvIndicator({super.key, required this.appInfo});

  /// Builds the widget tree showing environment info and device details.
  @override
  Widget build(BuildContext context) {
    if (appInfo.isProduction()) return const SizedBox.shrink();

    final textStyle = const TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
    );

    return Positioned(
      right: 16,
      top: appInfo.envHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: appInfo.envDotColor.withAlpha(150),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appInfo.build,
                  style: textStyle.copyWith(fontSize: 7, color: Colors.white),
                ),
                Text(
                  appInfo.env,
                  style: textStyle.copyWith(fontSize: 4, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RotatedBox(
            quarterTurns: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App (${appInfo.version}) - ${appInfo.osVersion}',
                  style: textStyle.copyWith(
                    fontSize: 6,
                    color: appInfo.envTextColor,
                  ),
                ),
                Text(
                  '${appInfo.deviceModel} - ${appInfo.deviceDetail}',
                  style: textStyle.copyWith(
                    fontSize: 6,
                    color: appInfo.envTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
