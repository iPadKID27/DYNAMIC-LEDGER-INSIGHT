import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netviewdemo/view/login_view.dart';
import 'package:netviewdemo/view/main_navigation.dart';
import 'package:netviewdemo/bloc/auth/auth_bloc.dart';
import 'package:netviewdemo/bloc/auth/auth_state.dart';
import 'package:netviewdemo/bloc/netview_bloc.dart';
import 'package:netviewdemo/bloc/netview_state.dart';

// Mocks
class MockAuthBloc extends Mock implements AuthBloc {}
class MockNetViewBloc extends Mock implements NetViewBloc {}

void main() {
  group('LoginView', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthState(status: AuthStatus.unauthenticated));
      when(() => authBloc.stream).thenAnswer((_) => Stream.value(authBloc.state));
    });

    Widget createWidget() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(value: authBloc, child: const LoginView()),
      );
    }

    testWidgets('shows error SnackBar on invalid email format (UTC-03)', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField).at(0), 'invalid-email'); // Email
      await tester.enterText(find.byType(TextField).at(1), 'password123'); // Password
      
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('shows error SnackBar on short password (UTC-04)', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), '12345'); // 5 chars
      
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('Manual Entry (MainNavigation)', () {
    late MockAuthBloc authBloc;
    late MockNetViewBloc netViewBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      netViewBloc = MockNetViewBloc();

      when(() => authBloc.state).thenReturn(const AuthState(
        status: AuthStatus.authenticated,
        userId: 'user123',
      ));
      when(() => authBloc.stream).thenAnswer((_) => Stream.value(authBloc.state));

      when(() => netViewBloc.state).thenReturn(const NetViewState());
      when(() => netViewBloc.stream).thenAnswer((_) => Stream.value(netViewBloc.state));
    });

    Widget createWidget() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<NetViewBloc>.value(value: netViewBloc),
          ],
          child: const MainNavigation(),
        ),
      );
    }

    testWidgets('shows error SnackBar when saving with empty amount/note (UTC-14)', (tester) async {
      await tester.pumpWidget(createWidget());

      // Tap Add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Add Entry'), findsOneWidget);

      // Ensure button is visible (it might be in a scroll view)
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();

      // Tap Save Entry without filling fields
      await tester.tap(saveButton);
      await tester.pump();

      // Verify SnackBar
      expect(find.text('Please enter a valid amount and note.'), findsOneWidget);
    });
  });
}
