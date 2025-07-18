import 'package:crelve_paw_harmony_ai/import/provider.dart';
import 'package:crelve_paw_harmony_ai/provider/auth_state_notifier.dart';
import 'package:crelve_paw_harmony_ai/provider/go_router_provider.dart';
import 'package:crelve_paw_harmony_ai/utility/const/shared_preferences_keys.dart';
import 'package.flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    mockFirebaseAuth = MockFirebaseAuth(
      signedIn: false,
    );
  });

  testWidgets('Auth flow test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const App(),
      ),
    );

    // 1. When the user signs up, a verification email is sent.
    await tester.tap(find.byKey(const Key('goToSignUp')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_form')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_form')), 'password123');
    await tester.enterText(find.byKey(const Key('confirm_password_form')), 'password123');
    await tester.tap(find.byKey(const Key('agree_checkbox')));
    await tester.tap(find.byKey(const Key('create_account_button')));
    await tester.pumpAndSettle();

    expect(mockFirebaseAuth.sendSignInLinkToEmailCalled, isTrue);
    expect(sharedPreferences.getString(SharedPreferencesKeys.email), 'test@example.com');

    // 2. The user is redirected to the EmailSentScreen.
    expect(find.byKey(const Key('email_sent_screen')), findsOneWidget);

    // 3. When the user clicks the verification link, the user is signed in.
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );

    await container.read(authStateNotifierProvider.notifier).signInWithEmailLink('https://example.com/link');
    await tester.pumpAndSettle();

    // After signing in, the user should be redirected to the home screen.
    // The user is signed in, but the email is not verified yet.
    expect(mockFirebaseAuth.currentUser, isNotNull);
    expect(mockFirebaseAuth.currentUser!.emailVerified, isFalse);

    // 6. The user is signed in automatically if the email is verified.
    mockFirebaseAuth.currentUser!.emailVerified = true;

    // We need to trigger a rebuild to reflect the new auth state.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_screen')), findsOneWidget);

    // 7. The user is prompted to resend the verification email if the email is not verified.
    await mockFirebaseAuth.signOut();
    await tester.pumpAndSettle();

    mockFirebaseAuth.currentUser!.emailVerified = false;
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_form')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_form')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email_not_verified_dialog')), findsOneWidget);
    expect(find.byKey(const Key('resend_email_button')), findsOneWidget);
  });
}
