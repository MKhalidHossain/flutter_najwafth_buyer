import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const Color backgroundColor = Color(0xFFF9F1E8);
  static const String logoAsset = 'assets/images/app_logo.png';

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.54,
            child: Image(image: AssetImage(logoAsset), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
