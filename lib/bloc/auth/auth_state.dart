import 'package:equatable/equatable.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.userId,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, userId, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
