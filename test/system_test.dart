import 'dart:async';
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
      return BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: LoginView()),
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

    testWidgets('shows network error SnackBar on signup failure (STC-01-TC-5)', (tester) async {
      final streamController = StreamController<AuthState>.broadcast();
      when(() => authBloc.stream).thenAnswer((_) => streamController.stream);
      when(() => authBloc.state).thenReturn(const AuthState(status: AuthStatus.unauthenticated));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      const errorState = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Network error occurred',
      );
      when(() => authBloc.state).thenReturn(errorState);
      streamController.add(errorState);
      await tester.pumpAndSettle();

      expect(find.text('Network error occurred'), findsOneWidget);
      await streamController.close();
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
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<NetViewBloc>.value(value: netViewBloc),
        ],
        child: const MaterialApp(
          home: MainNavigation(),
        ),
      );
    }

    testWidgets('shows error Dialog when saving with empty amount/note (UTC-14)', (tester) async {
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

    testWidgets('shows error Dialog when amount has >2 decimal places (UTC-14-TC-03)', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '30.123'); // Amount
      await tester.enterText(find.byType(TextField).at(0), 'Lunch'); // Note
      
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Amount can have at most 2 decimal places.'), findsOneWidget);
    });

    testWidgets('shows Confirmation Popup on valid input (UTC-14-TC-04)', (tester) async {
      // Needs fallback value for mocktail 'any()' or we just let it call. 
      // We don't strictly need verify() if we just check dialog closure.
      await tester.pumpWidget(createWidget());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '30.12'); // Amount
      await tester.enterText(find.byType(TextField).at(0), 'Lunch'); // Note
      
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify AlertDialog is shown
      expect(find.text('Confirm Entry'), findsOneWidget);
      expect(find.text('THB 30.12'), findsOneWidget);

      // Tap Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Confirm Entry'), findsNothing);
    });
  });
}
