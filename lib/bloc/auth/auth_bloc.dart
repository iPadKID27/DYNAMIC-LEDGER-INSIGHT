import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/auth_repository.dart';
import '../../model/user_profile.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _userSubscription;
  bool _isSigningUp = false;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _userSubscription = _authRepository.user.listen((user) {
      if (!_isSigningUp) {
        add(AuthUserChanged(user?.uid));
      }
    });
  }

  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    if (event.userId != null) {
      final profile = await _authRepository.getUserProfile(event.userId!);
      if (profile == null) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'User Profile Document Not Found',
        ));
        await _authRepository.logOut();
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: event.userId,
          userProfile: profile,
        ));
      }
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        userProfile: null,
      ));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.logIn(email: event.email, password: event.password);
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    _isSigningUp = true;
    try {
      final userCredential = await _authRepository.signUp(email: event.email, password: event.password);
      if (userCredential.user != null) {
        final profile = UserProfile(
          userId: userCredential.user!.uid,
          email: event.email,
          userName: event.userName,
          createdAt: DateTime.now(),
        );
        await _authRepository.createUserProfile(profile);
        
        _isSigningUp = false;
        add(AuthUserChanged(userCredential.user!.uid));
      }
    } catch (e) {
      _isSigningUp = false;
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
