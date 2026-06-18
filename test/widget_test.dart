import 'package:flutter_test/flutter_test.dart';

import 'package:notification_demo/main.dart';

void main() {
  testWidgets('shows role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Select Role'), findsOneWidget);
    expect(find.text('Choose Portal'), findsOneWidget);
    expect(find.text('Client Portal'), findsOneWidget);
    expect(find.text('Admin Portal'), findsOneWidget);
  });
}
