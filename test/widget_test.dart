// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_najwafth_buyer/app/app.dart';
import 'package:flutter_najwafth_buyer/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_najwafth_buyer/features/splash/presentation/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows splash shell on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = await AppBootstrap.createProviderScope(
      child: const NajwafthBuyerApp(),
    );

    await tester.pumpWidget(app);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(scaffold.backgroundColor, SplashPage.backgroundColor);
    expect(find.byType(Image), findsOneWidget);
  });
}
