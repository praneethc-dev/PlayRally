// Basic widget test for PlayRally app

import 'package:flutter_test/flutter_test.dart';
import 'package:play_rally/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlayRallyApp());

    // Verify splash screen shows
    expect(find.text('PLAY_RALLY'), findsOneWidget);
    expect(find.text('Scoring made simple'), findsOneWidget);
  });
}
