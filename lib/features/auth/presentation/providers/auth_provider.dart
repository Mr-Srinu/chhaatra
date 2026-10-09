import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
export '../../data/auth_repository.dart';
import '../../domain/usermodel.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repo;

  CurrentUserNotifier(this._repo) : super(UserModel.currentUser);

  void setUser(UserModel? user) {
    UserModel.currentUser = user;
    state = user;
  }

  Future<void> refreshUser() async {
    final firebaseUser = _repo.currentUser;
    if (firebaseUser != null) {
      var user = await _repo.fetchUserByUid(firebaseUser.uid);
      if (user == null && firebaseUser.email != null) {
        user = await _repo.fetchUserByEmail(firebaseUser.email!);
      }
      if (user != null) {
        setUser(user);
      }
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    setUser(null);
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(repo);
});

final authLoadingProvider = StateProvider<bool>((ref) => false);
