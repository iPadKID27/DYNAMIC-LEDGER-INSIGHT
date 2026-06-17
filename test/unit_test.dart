import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
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

// Mocks
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

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile(
      userId: '',
      email: '',
      fullName: '',
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

    test('signUp calls createUserWithEmailAndPassword', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, mockUserCredential);
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('createUserProfile saves profile to firestore', () async {
      final profile = UserProfile(
        userId: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        createdAt: DateTime.now(),
      );

      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(profile.userId)).thenReturn(mockDocument);
      when(() => mockDocument.set(any())).thenAnswer((_) async => {});

      await authRepository.createUserProfile(profile);

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollection.doc(profile.userId)).called(1);
      verify(() => mockDocument.set(profile.toDocument())).called(1);
    });

    test('getUserProfile returns profile from firestore', () async {
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
        'email': 'test@example.com',
        'fullName': 'Test User',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      final result = await authRepository.getUserProfile(userId);

      expect(result?.userId, userId);
      expect(result?.fullName, 'Test User');
    });

    test('logIn calls signInWithEmailAndPassword', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.logIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, mockUserCredential);
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('logOut calls signOut', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

      await authRepository.logOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });

  group('AuthBloc', () {
    late MockAuthRepository authRepository;
    late MockUser mockUser;

    setUp(() {
      authRepository = MockAuthRepository();
      mockUser = MockUser();
      
      when(() => authRepository.user).thenAnswer((_) => const Stream.empty());
      when(() => mockUser.uid).thenReturn('123');
    });

    test('initial state is AuthStatus.loading', () {
      expect(AuthBloc(authRepository: authRepository).state.status, AuthStatus.loading);
    });

    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when AuthUserChanged is added with userId',
      build: () {
        final profile = UserProfile(
          userId: '123',
          email: 'test@example.com',
          fullName: 'Test User',
          createdAt: DateTime.now(),
        );
        when(() => authRepository.getUserProfile('123')).thenAnswer((_) async => profile);
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthUserChanged('123')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated)
                        .having((s) => s.userId, 'userId', '123')
                        .having((s) => s.userProfile?.fullName, 'fullName', 'Test User'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when AuthUserChanged is added with null',
      build: () => AuthBloc(authRepository: authRepository),
      act: (bloc) => bloc.add(const AuthUserChanged(null)),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'calls signUp and createUserProfile on AuthSignUpRequested',
      build: () {
        final mockUserCredential = MockUserCredential();
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => authRepository.signUp(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => mockUserCredential);
        when(() => authRepository.createUserProfile(any())).thenAnswer((_) async => {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested('test@example.com', 'password', 'Test User')),
      verify: (_) {
        verify(() => authRepository.signUp(email: 'test@example.com', password: 'password')).called(1);
        verify(() => authRepository.createUserProfile(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'calls logIn on AuthLoginRequested',
      build: () {
        when(() => authRepository.logIn(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => MockUserCredential());
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested('test@example.com', 'password')),
      verify: (_) {
        verify(() => authRepository.logIn(email: 'test@example.com', password: 'password')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'calls logOut on AuthLogoutRequested',
      build: () {
        when(() => authRepository.logOut()).thenAnswer((_) async => {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      verify: (_) {
        verify(() => authRepository.logOut()).called(1);
      },
    );
  });

  group('LedgerRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late LedgerRepository ledgerRepository;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      ledgerRepository = LedgerRepository(firestore: mockFirestore);
    });

    test('addRecord adds a record to firestore', () async {
      final record = FinancialRecord(
        id: '1',
        userId: 'user123',
        amount: 500.0,
        date: DateTime.now(),
        note: 'Test record',
        type: RecordType.income,
        category: 'Active Income',
      );

      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.add(any())).thenAnswer((_) async => mockDocument);

      await ledgerRepository.addRecord(record);

      verify(() => mockFirestore.collection('records')).called(1);
      verify(() => mockCollection.add(record.toDocument())).called(1);
    });

    test('getRecords returns a stream of records for a user', () {
      const userId = 'user123';
      final mockCollection = MockCollectionReference();
      final mockQuery1 = MockQuery();
      final mockQuery2 = MockQuery();

      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery1);
      when(() => mockQuery1.orderBy('date', descending: true)).thenReturn(mockQuery2);
      when(() => mockQuery2.snapshots()).thenAnswer((_) => Stream.value(MockQuerySnapshot()));

      final result = ledgerRepository.getRecords(userId);

      expect(result, isA<Stream<List<FinancialRecord>>>());
      verify(() => mockFirestore.collection('records')).called(1);
      verify(() => mockCollection.where('userId', isEqualTo: userId)).called(1);
    });

    test('deleteRecord deletes a record from firestore', () async {
      const recordId = 'record123';
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(() => mockFirestore.collection('records')).thenReturn(mockCollection);
      when(() => mockCollection.doc(recordId)).thenReturn(mockDocument);
      when(() => mockDocument.delete()).thenAnswer((_) async => {});

      await ledgerRepository.deleteRecord(recordId);

      verify(() => mockFirestore.collection('records')).called(1);
      verify(() => mockCollection.doc(recordId)).called(1);
      verify(() => mockDocument.delete()).called(1);
    });
  });

  group('NetViewBloc', () {
    late MockLedgerRepository ledgerRepository;

    setUp(() {
      ledgerRepository = MockLedgerRepository();
    });

    test('initial state is LedgerStatus.initial', () {
      expect(NetViewBloc(ledgerRepository: ledgerRepository).state.status, LedgerStatus.initial);
    });

    blocTest<NetViewBloc, NetViewState>(
      'emits [loading, success] when LedgerSubscriptionRequested is added',
      build: () {
        when(() => ledgerRepository.getRecords(any())).thenAnswer((_) => Stream.value([]));
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerSubscriptionRequested('user123')),
      expect: () => [
        const NetViewState(status: LedgerStatus.loading),
        const NetViewState(status: LedgerStatus.success, records: []),
      ],
    );

    blocTest<NetViewBloc, NetViewState>(
      'calls addRecord on LedgerRecordAdded',
      build: () {
        when(() => ledgerRepository.addRecord(any())).thenAnswer((_) async => {});
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) {
        final record = FinancialRecord(
          id: '1',
          userId: 'user123',
          amount: 100,
          date: DateTime.now(),
          note: 'test',
          type: RecordType.expense,
          category: 'Variable Outflows',
        );
        bloc.add(LedgerRecordAdded(record));
      },
      verify: (_) {
        verify(() => ledgerRepository.addRecord(any())).called(1);
      },
    );

    blocTest<NetViewBloc, NetViewState>(
      'calls deleteRecord on LedgerRecordDeleted',
      build: () {
        when(() => ledgerRepository.deleteRecord(any())).thenAnswer((_) async => {});
        return NetViewBloc(ledgerRepository: ledgerRepository);
      },
      act: (bloc) => bloc.add(const LedgerRecordDeleted('record123')),
      verify: (_) {
        verify(() => ledgerRepository.deleteRecord('record123')).called(1);
      },
    );
  });
}
