// Basic smoke test: the app boots and shows the BLOOM branding immediately.
//
// This deliberately does not wait on the real SQLite load — sqflite_common_ffi
// talks to a background isolate, and Flutter's fake-clock test zone doesn't
// reliably resolve that inside `testWidgets` even via `tester.runAsync`. The
// real data-layer behavior (account/transaction/goal business logic against
// a real database) is covered by the plain `test()`s in services_test.dart,
// which run outside that fake zone.

import 'package:flutter_test/flutter_test.dart';

import 'package:bloom/main.dart';

void main() {
  testWidgets('BLOOM app boots and shows its branding', (WidgetTester tester) async {
    await tester.pumpWidget(const BloomApp());
    await tester.pump();

    expect(find.text('BLOOM'), findsOneWidget);
    expect(find.text('Track. Save. Bloom.'), findsOneWidget);
  });
}
