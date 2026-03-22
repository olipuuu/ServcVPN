import 'package:flutter_test/flutter_test.dart';
import 'package:servc_vpn/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ServcVPNApp());
    expect(find.text('ServcVPN'), findsOneWidget);
  });
}
