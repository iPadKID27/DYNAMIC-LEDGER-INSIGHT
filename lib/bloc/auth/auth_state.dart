import 'package:equatable/equatable.dart';
import '../../model/user_profile.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final UserProfile? userProfile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.userId,
    this.userProfile,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, userId, userProfile, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    UserProfile? userProfile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
