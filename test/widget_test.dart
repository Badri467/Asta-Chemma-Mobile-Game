import 'package:ashta_chemma/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows offline test controls without connecting automatically', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Offline connection test'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Start host on this phone'), findsOneWidget);
    expect(find.text('Connect / reconnect to host'), findsOneWidget);
  });
}
