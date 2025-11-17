import 'package:flutter_test/flutter_test.dart';
import 'package:latres_prak_mobile/main.dart';

void main() {
  testWidgets('App starts at login page when not logged in', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    expect(find.text('Selamat Datang di Otsu'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Register'), findsOneWidget);
  });
}