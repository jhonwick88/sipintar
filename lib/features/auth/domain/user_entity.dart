class UserEntity {
  final String uid;
  final String email;
  final String role; // 'dev' | 'admin' | 'user'

  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
  });
}
