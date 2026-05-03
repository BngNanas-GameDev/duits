import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:duits/main.dart';
import 'package:duits/providers/auth_provider.dart';
import 'package:duits/providers/couple_provider.dart';

void main() {
  testWidgets('Duits app shows login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(enableLocalAuth: false),
          ),
          ChangeNotifierProvider(create: (_) => CoupleProvider()),
        ],
        child: const DuitsApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Duits'), findsOneWidget);
    expect(find.text('Login Akun'), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
  });
}
