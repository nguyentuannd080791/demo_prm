import 'package:bookstore/app/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simulate login and hot restart session restore', () async {
    SharedPreferences.setMockInitialValues({});
    await AppDependencies.create();

    // Directly test save and restore or through AuthLocalDataSource
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setString('auth_token', 'mock_token');
    await prefs.setString(
      'auth_user',
      '{"userId":1,"username":"testuser","role":"CUSTOMER"}',
    );

    // Simulate Hot Restart: new isolate creates new AppDependencies and calls restoreSession
    final deps2 = await AppDependencies.create();
    expect(deps2.authProvider.user, isNull);
    expect(deps2.authProvider.isAuthenticated, isFalse);

    await deps2.authProvider.restoreSession();

    expect(deps2.authProvider.user, isNotNull);
    expect(deps2.authProvider.user!.username, 'testuser');
    expect(deps2.authProvider.isAuthenticated, isTrue);

    // Logout
    await deps2.authProvider.logout();
    expect(deps2.authProvider.user, isNull);
    expect(deps2.authProvider.isAuthenticated, isFalse);
    expect(prefs.getString('auth_token'), isNull);
    expect(prefs.getString('auth_user'), isNull);
  });

  test('no session in storage returns null user', () async {
    SharedPreferences.setMockInitialValues({});
    final deps = await AppDependencies.create();
    await deps.authProvider.restoreSession();
    expect(deps.authProvider.user, isNull);
    expect(deps.authProvider.isAuthenticated, isFalse);
  });
}
