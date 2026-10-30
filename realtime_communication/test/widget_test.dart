import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_communication/main.dart';

void main() {
  testWidgets('Realtime Communication App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RealtimeCommunicationApp());
    expect(find.text('Realtime Communication'), findsOneWidget);
  });
}
