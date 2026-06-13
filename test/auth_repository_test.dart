import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netviewdemo/repository/auth_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authRepository = AuthRepository(firebaseAuth: mockFirebaseAuth);
  });

  group('AuthRepository', () {
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
}
