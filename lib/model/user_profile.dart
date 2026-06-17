import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, email, fullName, createdAt];

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      'fullName': fullName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
