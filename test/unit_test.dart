import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netviewdemo/bloc/auth/auth_bloc.dart';
import 'package:netviewdemo/bloc/auth/auth_event.dart';
import 'package:netviewdemo/bloc/auth/auth_state.dart';
import 'package:netviewdemo/repository/auth_repository.dart';
import 'package:netviewdemo/model/user_profile.dart';
import 'package:netviewdemo/repository/ledger_repository.dart';
import 'package:netviewdemo/model/financial_record.dart';
import 'package:netviewdemo/bloc/netview_bloc.dart';
import 'package:netviewdemo/bloc/netview_event.dart';
import 'package:netviewdemo/bloc/netview_state.dart';
import 'package:netviewdemo/view/login_view.dart';
import 'package:netviewdemo/view/main_navigation.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements AuthRepository {}
class MockLedgerRepository extends Mock implements LedgerRepository {}
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockUser extends Mock implements firebase_auth.User {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockAuthBloc extends Mock implements AuthBloc {}
class MockNetViewBloc extends Mock implements NetViewBloc {}

// ── Fakes (required by mocktail for any() matchers) ───────────────────────
class FakeNetViewEvent extends Fake implements NetViewEvent {}
class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNetViewEvent());
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(UserProfile(
      userId: '',
      email: '',
      userName: '',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(FinancialRecord(
      id: '',
      userId: '',
      amount: 0,
      date: DateTime.now(),
      note: '',
      type: RecordType.expense,
      category: '',
    ));
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-01 & UTC-02  |  FinancialRecord Model
  // Module: lib/model/financial_record.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('FinancialRecord Model', () {
    final fixedDate = DateTime(2025, 6, 1, 12, 0);

    // UTC-01-TC-01: toDocument – income record
    test('UTC-01-TC-01: toDocument serializes income record correctly', () {
      final record = FinancialRecord(
        id: 'r1', userId: 'u1', amount: 5000.0,
        date: fixedDate, note: 'Salary',
        type: RecordType.income, category: 'Active Income',
      );
      final doc = record.toDocument();
      expect(doc['userId'], 'u1');
      expect(doc['amount'], 5000.0);
      expect(doc['note'], 'Salary');
      expect(doc['category'], 'Active Income');
      expect(doc['type'], 'income');
      expect(doc['assetSymbol'], isNull);
      expect(doc['assetQuantity'], isNull);
      expect(doc['date'], isA<Timestamp>());
    });

    // UTC-01-TC-02: toDocument – asset record with symbol and quantity
    test('UTC-01-TC-02: toDocument serializes asset record with symbol and quantity', () {
      final record = FinancialRecord(
        id: 'r2', userId: 'u1', amount: 150000.0,
        date: fixedDate, note: 'Bought BTC',
        type: RecordType.asset, category: 'Investment Assets',
        assetSymbol: 'BTC', assetQuantity: 0.5,
      );
      final doc = record.toDocument();
      expect(doc['type'], 'asset');
      expect(doc['assetSymbol'], 'BTC');
      expect(doc['assetQuantity'], 0.5);
    });

    // UTC-01-TC-03: toDocument – expense record (asset fields must be null)
    test('UTC-01-TC-03: toDocument expense record has null asset fields', () {
      final record = FinancialRecord(
        id: 'r3', userId: 'u1', amount: 250.0,
        date: fixedDate, note: 'Lunch',
        type: RecordType.expense, category: 'Variable Outflows',
      );
      final doc = record.toDocument();
      expect(doc['type'], 'expense');
      expect(doc['assetSymbol'], isNull);
      expect(doc['assetQuantity'], isNull);
    });

    // UTC-02-TC-01: fromDocument – expense record
    test('UTC-02-TC-01: fromDocument deserializes expense record correctly', () {
      final mockSnap = MockDocumentSnapshot();
      when(() => mockSnap.id).thenReturn('r3');
      when(() => mockSnap.data()).thenReturn({
        'userId': 'u1', 'amount': 250.0,
        'date': Timestamp.fromDate(fixedDate),
        'note': 'Lunch', 'type': 'expense',
        'category': 'Variable Outflows',
        'assetSymbol': null, 'assetQuantity': null,
      });
      final record = FinancialRecord.fromDocument(mockSnap);
      expect(record.id, 'r3');
      expect(record.userId, 'u1');
      expect(record.amount, 250.0);
      expect(record.type, RecordType.expense);
      expect(record.category, 'Variable Outflows');
      expect(record.assetSymbol, isNull);
      expect(record.assetQuantity, isNull);
    });

    // UTC-02-TC-02: fromDocument – asset record (symbol + quantity populated)
    test('UTC-02-TC-02: fromDocument deserializes asset record with symbol and quantity', () {
      final mockSnap = MockDocumentSnapshot();
      when(() => mockSnap.id).thenReturn('r4');
      when(() => mockSnap.data()).thenReturn({
        'userId': 'u1', 'amount': 150000.0,
        'date': Timestamp.fromDate(fixedDate),
        'note': 'Bought BTC', 'type': 'asset',
        'category': 'Investment Assets',
        'assetSymbol': 'BTC', 'assetQuantity': 0.5,
      });
      final record = FinancialRecord.fromDocument(mockSnap);
      expect(record.id, 'r4');
      expect(record.type, RecordType.asset);
      expect(record.assetSymbol, 'BTC');
      expect(record.assetQuantity, 0.5);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-UP  |  UserProfile Model
  // Module: lib/model/user_profile.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('UserProfile Model', () {
    final fixedDate = DateTime(2025, 1, 1, 0, 0);

    // UTC-UP-TC-01: toDocument – serializes all fields correctly
    test('UTC-UP-TC-01: toDocument serializes email, fullName, and createdAt', () {
      final profile = UserProfile(
        userId: 'u1',
        email: 'test@example.com',
        userName: 'Test User',
        createdAt: fixedDate,
      );
      final doc = profile.toDocument();
      expect(doc['email'], 'test@example.com');
      expect(doc['fullName'], 'Test User');
      expect(doc['createdAt'], isA<Timestamp>());
      // userId must NOT be inside the document body (it becomes the Firestore doc ID)
      expect(doc.containsKey('userId'), isFalse);
    });

    // UTC-UP-TC-02: fromDocument – deserializes all fields correctly
    test('UTC-UP-TC-02: fromDocument deserializes userId from doc.id and all fields', () {
      final mockSnap = MockDocumentSnapshot();
      when(() => mockSnap.id).thenReturn('u1');
      when(() => mockSnap.data()).thenReturn({
        'email': 'test@example.com',
        'fullName': 'Test User',
        'createdAt': Timestamp.fromDate(fixedDate),
      });
      final profile = UserProfile.fromDocument(mockSnap);
      expect(profile.userId, 'u1');
      expect(profile.email, 'test@example.com');
      expect(profile.userName, 'Test User');
      expect(profile.createdAt, fixedDate);
    });

    // UTC-UP-TC-03: fromDocument – missing fields fall back to empty string
    test('UTC-UP-TC-03: fromDocument uses empty string when email or fullName is absent', () {
      final mockSnap = MockDocumentSnapshot();
      when(() => mockSnap.id).thenReturn('u2');
      when(() => mockSnap.data()).thenReturn({
        'createdAt': Timestamp.fromDate(fixedDate),
        // email and fullName intentionally absent
      });
      final profile = UserProfile.fromDocument(mockSnap);
      expect(profile.email, '');
      expect(profile.userName, '');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-03  |  AuthRepository.signUp
  // UTC-04  |  AuthRepository.logIn
  // UTC-05  |  AuthRepository.createUserProfile
  // UTC-06  |  AuthRepository.getUserProfile
  // UTC-07  |  AuthRepository.logOut
  // Module: lib/repository/auth_repository.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRepository', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late AuthRepository authRepository;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      authRepository = AuthRepository(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    // UTC-03-TC-01: signUp success – returns UserCredential
    test('UTC-03-TC-01: signUp returns UserCredential on success', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com', password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.signUp(
        email: 'test@example.com', password: 'password123',
      );
      expect(result, mockUserCredential);
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com', password: 'password123',
      )).called(1);
    });

    // UTC-03-TC-02: signUp failure – email-already-in-use throws specific message
    test('UTC-03-TC-02: signUp throws "already registered" for email-already-in-use', () {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'), password: any(named: 'password'),
      )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => authRepository.signUp(
            email: 'taken@example.com', password: 'pw123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('already registered'),
        )),
      );
    });

    // UTC-03-TC-03: signUp failure – weak-password throws specific message
    test('UTC-03-TC-03: signUp throws "weak" message for weak-password', () {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'), password: any(named: 'password'),
      )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'weak-password'));

      expect(
        () => authRepository.signUp(
            email: 'test@example.com', password: '123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('weak'),
        )),
      );
    });

    // UTC-04-TC-01: logIn success – returns UserCredential
    test('UTC-04-TC-01: logIn returns UserCredential on success', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com', password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.logIn(
        email: 'test@example.com', password: 'password123',
      );
      expect(result, mockUserCredential);
    });

    // UTC-04-TC-02: logIn failure – wrong-password throws specific message
    test('UTC-04-TC-02: logIn throws "Invalid" message for wrong-password', () {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'), password: any(named: 'password'),
      )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authRepository.logIn(
            email: 'test@example.com', password: 'wrong'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('Invalid'),
        )),
      );
    });

    // UTC-05-TC-01: createUserProfile – saves serialized document to Firestore
    test('UTC-05-TC-01: createUserProfile saves profile to Firestore', () async {
      final profile = UserProfile(
        userId: '123', email: 'test@example.com',
        userName: 'Test User', createdAt: DateTime.now(),
      );
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(profile.userId)).thenReturn(mockDocument);
      when(() => mockDocument.set(any())).thenAnswer((_) async {});

      await authRepository.createUserProfile(profile);

      verify(() => mockDocument.set(profile.toDocument())).called(1);
    });

    // UTC-06-TC-01: getUserProfile – returns UserProfile when document exists
    test('UTC-06-TC-01: getUserProfile returns UserProfile when document exists', () async {
      const userId = '123';
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(userId)).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.id).thenReturn(userId);
      when(() => mockSnapshot.data()).thenReturn({
        'email': 'test@example.com', 'fullName': 'Test User',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      final result = await authRepository.getUserProfile(userId);
      expect(result?.userId, userId);
      expect(result?.userName, 'Test User');
    });

    // UTC-06-TC-02: getUserProfile – returns null when document does not exist
    test('UTC-06-TC-02: getUserProfile returns null when document does not exist', () async {
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('ghost')).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      final result = await authRepository.getUserProfile('ghost');
      expect(result, isNull);
    });

    // UTC-07-TC-01: logOut – calls Firebase signOut exactly once
    test('UTC-07-TC-01: logOut calls signOut once', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      await authRepository.logOut();
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-08  |  AuthBloc
  // Module: lib/bloc/auth/auth_bloc.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthBloc', () {
    late MockAuthRepository authRepository;
    late MockUser mockUser;

    setUp(() {
      authRepository = MockAuthRepository();
      mockUser = MockUser();
      when(() => authRepository.user).thenAnswer((_) => const Stream.empty());
      when(() => mockUser.uid).thenReturn('123');
    });

    // UTC-08-TC-01: initial state is AuthStatus.loading
    test('UTC-08-TC-01: initial state is AuthStatus.loading', () {
      expect(
        AuthBloc(authRepository: authRepository).state.status,
        AuthStatus.loading,
      );
    });

    // UTC-08-TC-02: AuthUserChanged with userId → emits authenticated
    blocTest<AuthBloc, AuthState>(
      'UTC-08-TC-02: AuthUserChanged with userId emits authenticated state',
      build: () {
        final profile = UserProfile(
          userId: '123', email: 'test@example.com',
          userName: 'Test User', createdAt: DateTime.now(),
        );
        when(() => authRepository.getUserProfile('123'))
            .thenAnswer((_) async => profile);
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthUserChanged('123')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.userId, 'userId', '123')
            .having((s) => s.userProfile?.userName, 'fullName', 'Test User'),
      ],
    );

    // UTC-08-TC-03: AuthUserChanged with null → emits unauthenticated
    blocTest<AuthBloc, AuthState>(
      'UTC-08-TC-03: AuthUserChanged with null emits unauthenticated state',
      build: () => AuthBloc(authRepository: authRepository),
      act: (bloc) => bloc.add(const AuthUserChanged(null)),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    // UTC-08-TC-04: AuthLoginRequested failure → emits [loading, error]
    blocTest<AuthBloc, AuthState>(
      'UTC-08-TC-04: AuthLoginRequested failure emits [loading, error]',
      build: () {
        when(() => authRepository.logIn(
          email: any(named: 'email'), password: any(named: 'password'),
        )).thenThrow(Exception('wrong-password'));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) =>
          bloc.add(const AuthLoginRequested('test@example.com', 'wrongpass')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    // UTC-08-TC-05: AuthSignUpRequested failure → emits [loading, error]
    blocTest<AuthBloc, AuthState>(
      'UTC-08-TC-05: AuthSignUpRequested failure emits [loading, error]',
      build: () {
        when(() => authRepository.signUp(
          email: any(named: 'email'), password: any(named: 'password'),
        )).thenThrow(Exception('email-already-in-use'));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(
          const AuthSignUpRequested('taken@example.com', 'pass123', 'User')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    // UTC-08-TC-06: AuthUserChanged with userId but getUserProfile returns null
    //              → emits error state AND calls logOut
    blocTest<AuthBloc, AuthState>(
      'UTC-08-TC-06: AuthUserChanged emits error and calls logOut when profile not found',
      build: () {
        when(() => authRepository.getUserProfile('orphan'))
            .thenAnswer((_) async => null);
        when(() => authRepository.logOut()).thenAnswer((_) async {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthUserChanged('orphan')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
      verify: (_) {
        verify(() => authRepository.logOut()).called(1);
      },
    );

    // Additional behaviour coverage
    blocTest<AuthBloc, AuthState>(
      'calls signUp and createUserProfile on AuthSignUpRequested',
      build: () {
        final mockUserCredential = MockUserCredential();
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => authRepository.signUp(
          email: any(named: 'email'), password: any(named: 'password'),
        )).thenAnswer((_) async => mockUserCredential);
        when(() => authRepository.getUserProfile(any()))
            .thenAnswer((_) async => UserProfile(
              userId: '123', email: 'test@example.com',
              userName: 'Test User', createdAt: DateTime.now(),
            ));
        when(() => authRepository.createUserProfile(any()))
            .thenAnswer((_) async {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(
          const AuthSignUpRequested('test@example.com', 'password', 'Test User')),
      verify: (_) {
        verify(() => authRepository.signUp(
                email: 'test@example.com', password: 'password'))
            .called(1);
        verify(() => authRepository.createUserProfile(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'calls logIn on AuthLoginRequested',
      build: () {
        when(() => authRepository.logIn(
          email: any(named: 'email'), password: any(named: 'password'),
        )).thenAnswer((_) async => MockUserCredential());
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) =>
          bloc.add(const AuthLoginRequested('test@example.com', 'password')),
      verify: (_) {
        verify(() => authRepository.logIn(
                email: 'test@example.com', password: 'password'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'calls logOut on AuthLogoutRequested',
      build: () {
        when(() => authRepository.logOut()).thenAnswer((_) async {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      verify: (_) {
        verify(() => authRepository.logOut()).called(1);
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-09 & UTC-10  |  LedgerRepository
  // Module: lib/repository/ledger_repository.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('LedgerRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late LedgerRepository ledgerRepository;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      ledgerRepository = LedgerRepository(firestore: mockFirestore);
    });

    // UTC-09-TC-01: addRecord – persists serialized document to Firestore
    test('UTC-09-TC-01: addRecord persists record to Firestore', () async {
      final record = FinancialRecord(
        id: '1', userId: 'user123', amount: 500.0,
        date: DateTime.now(), note: 'Test record',
        type: RecordType.income, category: 'Active Income',
      );
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.add(any())).thenAnswer((_) async => mockDocument);

      await ledgerRepository.addRecord(record);
      verify(() => mockCollection.add(record.toDocument())).called(1);
    });


    // UTC-10-TC-01: deleteRecord – removes the correct Firestore document
    test('UTC-10-TC-01: deleteRecord removes the correct Firestore document', () async {
      const recordId = 'record123';
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.doc(recordId)).thenReturn(mockDocument);
      when(() => mockDocument.delete()).thenAnswer((_) async {});

      await ledgerRepository.deleteRecord(recordId);
      verify(() => mockDocument.delete()).called(1);
    });

    // UTC-10-TC-02: updateRecord – writes updated data to correct document
    test('UTC-10-TC-02: updateRecord writes updated data to correct Firestore document', () async {
      final record = FinancialRecord(
        id: 'r1', userId: 'u1', amount: 999.0,
        date: DateTime.now(), note: 'Updated',
        type: RecordType.income, category: 'Active Income',
      );
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.doc('r1')).thenReturn(mockDocument);
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await ledgerRepository.updateRecord(record);
      verify(() => mockCollection.doc('r1')).called(1);
      verify(() => mockDocument.update(record.toDocument())).called(1);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-11  |  NetViewBloc
  // Module: lib/bloc/netview_bloc.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('NetViewBloc', () {
    late MockLedgerRepository ledgerRepository;

    setUp(() {
      ledgerRepository = MockLedgerRepository();
    });

    // UTC-11-TC-01: initial state is LedgerStatus.initial
    test('UTC-11-TC-01: initial state is LedgerStatus.initial', () {
      expect(
        NetViewBloc(ledgerRepository: ledgerRepository).state.status,
        LedgerStatus.initial,
      );
    });

    // UTC-11-TC-02: LedgerSubscriptionRequested – emits [loading, success] with empty list
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-02: LedgerSubscriptionRequested emits [loading, success] with empty list',
      build: () {
        when(() => ledgerRepository.getRecords(any()))
            .thenAnswer((_) => Stream.value([]));
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerSubscriptionRequested('user123')),
      expect: () => [
        const NetViewState(status: LedgerStatus.loading),
        const NetViewState(status: LedgerStatus.success, records: []),
      ],
    );

    // UTC-11-TC-03: LedgerSubscriptionRequested – emits success with actual records
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-03: LedgerSubscriptionRequested emits success with actual records',
      build: () {
        final records = [
          FinancialRecord(
            id: 'r1', userId: 'u1', amount: 5000.0,
            date: DateTime.now(), note: 'Salary',
            type: RecordType.income, category: 'Active Income',
          ),
        ];
        when(() => ledgerRepository.getRecords(any()))
            .thenAnswer((_) => Stream.value(records));
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerSubscriptionRequested('u1')),
      expect: () => [
        const NetViewState(status: LedgerStatus.loading),
        isA<NetViewState>()
            .having((s) => s.status, 'status', LedgerStatus.success)
            .having((s) => s.records.length, 'records.length', 1)
            .having((s) => s.records.first.note, 'note', 'Salary'),
      ],
    );


    // UTC-11-TC-04: LedgerRecordAdded – calls addRecord on repository
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-04: LedgerRecordAdded calls addRecord on repository',
      build: () {
        when(() => ledgerRepository.addRecord(any())).thenAnswer((_) async {});
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) {
        final record = FinancialRecord(
          id: '1', userId: 'u1', amount: 100,
          date: DateTime.now(), note: 'test',
          type: RecordType.expense, category: 'Variable Outflows',
        );
        bloc.add(LedgerRecordAdded(record));
      },
      verify: (_) {
        verify(() => ledgerRepository.addRecord(any())).called(1);
      },
    );

    // UTC-11-TC-05: LedgerRecordAdded failure → emits error state
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-05: LedgerRecordAdded failure emits error state',
      build: () {
        when(() => ledgerRepository.addRecord(any()))
            .thenThrow(Exception('Firestore write failed'));
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) {
        final record = FinancialRecord(
          id: '', userId: 'u1', amount: 100.0,
          date: DateTime.now(), note: 'fail',
          type: RecordType.expense, category: 'Variable Outflows',
        );
        bloc.add(LedgerRecordAdded(record));
      },
      expect: () => [
        isA<NetViewState>()
            .having((s) => s.status, 'status', LedgerStatus.error),
      ],
    );

    // UTC-11-TC-06: LedgerRecordDeleted – calls deleteRecord on repository
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-06: LedgerRecordDeleted calls deleteRecord on repository',
      build: () {
        when(() => ledgerRepository.deleteRecord(any()))
            .thenAnswer((_) async {});
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerRecordDeleted('record123')),
      verify: (_) {
        verify(() => ledgerRepository.deleteRecord('record123')).called(1);
      },
    );

    // UTC-11-TC-07: LedgerRecordDeleted failure → emits error state
    blocTest<NetViewBloc, NetViewState>(
      'UTC-11-TC-07: LedgerRecordDeleted failure emits error state',
      build: () {
        when(() => ledgerRepository.deleteRecord(any()))
            .thenThrow(Exception('Firestore delete failed'));
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerRecordDeleted('r1')),
      expect: () => [
        isA<NetViewState>()
            .having((s) => s.status, 'status', LedgerStatus.error),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-12 & UTC-13  |  LoginView  (Widget Tests)
  // Module: lib/view/login_view.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('LoginView', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state)
          .thenReturn(const AuthState(status: AuthStatus.unauthenticated));
      when(() => authBloc.stream)
          .thenAnswer((_) => Stream.value(authBloc.state));
    });

    Widget createWidget() => MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const LoginView(),
          ),
        );

    // UTC-12-TC-01: empty fields → "Please fill in all fields" SnackBar
    testWidgets('UTC-12-TC-01: empty fields show "Please fill in all fields" SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    // UTC-12-TC-02: invalid email format → error SnackBar
    testWidgets('UTC-12-TC-02: invalid email format shows error SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Invalid email format'), findsOneWidget);
    });

    // UTC-12-TC-03: password < 6 chars → error SnackBar
    testWidgets('UTC-12-TC-03: short password shows error SnackBar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), '12345');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // UTC-12-TC-04: valid credentials → dispatches AuthLoginRequested
    testWidgets('UTC-12-TC-04: valid credentials dispatch AuthLoginRequested',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      verify(() => authBloc.add(
            const AuthLoginRequested('test@example.com', 'password123'),
          )).called(1);
    });

    // UTC-12-TC-05: valid sign-up → dispatches AuthSignUpRequested with correct fullName
    testWidgets(
        'UTC-12-TC-05: valid sign-up dispatches AuthSignUpRequested with fullName',
        (tester) async {
      await tester.pumpWidget(createWidget());
      // Switch to sign-up mode
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();
      // Sign-up mode TextField order: fullName(0), email(1), password(2)
      await tester.enterText(find.byType(TextField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      verify(() => authBloc.add(
            const AuthSignUpRequested('john@example.com', 'password123', 'John Doe'),
          )).called(1);
    });

    // UTC-12-TC-06: [KNOWN BUG] empty fullName silently defaults to 'New User'
    //              Expected behaviour: show validation error
    //              Actual behaviour:   submits with 'New User' (no error shown)
    testWidgets(
        'UTC-12-TC-06: [KNOWN BUG] empty fullName defaults to "New User" without error',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();
      // Leave fullName (TextField at 0) intentionally empty
      await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      // BUG: code does `fullName.isEmpty ? 'New User' : fullName` — no validation error
      verify(() => authBloc.add(
            const AuthSignUpRequested('john@example.com', 'password123', 'New User'),
          )).called(1);
    });

    // UTC-13-TC-01: toggle → switches to Sign Up form
    testWidgets('UTC-13-TC-01: tapping toggle switches to Sign Up form',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UTC-14  |  MainNavigation — Add Entry Dialog  (Widget Tests)
  // Module: lib/view/main_navigation.dart
  // ══════════════════════════════════════════════════════════════════════════
  group('MainNavigation – Add Entry Dialog', () {
    late MockAuthBloc authBloc;
    late MockNetViewBloc netViewBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      netViewBloc = MockNetViewBloc();
      when(() => authBloc.state).thenReturn(const AuthState(
        status: AuthStatus.authenticated, userId: 'user123',
      ));
      when(() => authBloc.stream)
          .thenAnswer((_) => Stream.value(authBloc.state));
      when(() => netViewBloc.state).thenReturn(const NetViewState());
      when(() => netViewBloc.stream)
          .thenAnswer((_) => Stream.value(netViewBloc.state));
    });

    Widget createWidget() => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<NetViewBloc>.value(value: netViewBloc),
          ],
          child: const MaterialApp(home: MainNavigation()),
        );

    Future<void> openAddEntry(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }

    // UTC-14-TC-01: empty note/amount → shows "Invalid Input" dialog
    testWidgets('UTC-14-TC-01: empty note and amount shows "Invalid Input" dialog',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      expect(find.text('Add Entry'), findsOneWidget);
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text('Invalid Input'), findsOneWidget);
      expect(find.text('Please enter a valid amount and note.'), findsOneWidget);
    });

    // UTC-14-TC-02: switching to ASSET type shows Symbol and Quantity fields
    testWidgets('UTC-14-TC-02: switching to ASSET type shows Symbol and Quantity fields',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      await tester.tap(find.text('ASSET'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'BTC, Gold, AAPL'), findsOneWidget);
      expect(find.widgetWithText(TextField, '0.0'), findsOneWidget);
    });

    // UTC-14-TC-03: valid entry → Confirm Entry dialog appears
    testWidgets('UTC-14-TC-03: valid entry shows Confirm Entry dialog on Save',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g., Dinner at Siam'), 'Lunch');
      await tester.enterText(find.widgetWithText(TextField, '0.00'), '300');
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text('Confirm Entry'), findsOneWidget);
    });

    // UTC-14-TC-04: tapping Confirm dispatches LedgerRecordAdded
    testWidgets('UTC-14-TC-04: tapping Confirm dispatches LedgerRecordAdded',
        (tester) async {
      when(() => netViewBloc.add(any())).thenReturn(null);
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g., Dinner at Siam'), 'Salary');
      await tester.enterText(find.widgetWithText(TextField, '0.00'), '5000');
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle(); // Confirm dialog appears
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      verify(() => netViewBloc.add(any(that: isA<LedgerRecordAdded>()))).called(1);
    });

    // UTC-14-TC-05: Cancel in Confirm dialog closes dialog; bottom sheet stays open
    testWidgets(
        'UTC-14-TC-05: Cancel in Confirm dialog closes dialog but bottom sheet stays',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g., Dinner at Siam'), 'Coffee');
      await tester.enterText(find.widgetWithText(TextField, '0.00'), '300');
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text('Confirm Entry'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Entry'), findsNothing); // dialog closed
      expect(find.text('Add Entry'), findsOneWidget);   // bottom sheet still open
    });

    // UTC-14-TC-06: amount with >2 decimal places → "Invalid Amount" dialog
    //              (applies to INCOME/EXPENSE only, not ASSET)
    testWidgets(
        'UTC-14-TC-06: amount >2 decimal places shows "Invalid Amount" dialog',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await openAddEntry(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g., Dinner at Siam'), 'Coffee');
      await tester.enterText(find.widgetWithText(TextField, '0.00'), '5.123');
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text('Invalid Amount'), findsOneWidget);
      expect(find.text('Amount can have at most 2 decimal places.'), findsOneWidget);
    });
  });
}