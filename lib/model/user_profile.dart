import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String email;
  final String userName;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.userName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, email, userName, createdAt];

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      email: data['email'] ?? '',
      userName: data['userName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
