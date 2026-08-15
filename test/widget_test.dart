import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fix_near/main.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('FixNear App smoke test', (WidgetTester tester) async {
    // Ignore network image 400 exceptions during flutter test
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('NetworkImageLoadException') ||
          details.exception.toString().contains('HTTP request failed')) {
        return;
      }
      FlutterError.presentError(details);
    };

    // Build FixNearApp and trigger a frame.
    await tester.pumpWidget(const FixNearApp());
    await tester.pump(const Duration(seconds: 2));

    // Verify that the title appears
    expect(find.text('FixNear'), findsOneWidget);

    // Unmount widget tree cleanly
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
