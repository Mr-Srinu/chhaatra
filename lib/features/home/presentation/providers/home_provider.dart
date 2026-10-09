import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_posts_repository.dart';

final homeTabProvider = StateProvider<int>((ref) => 0);

class HomePostsState {
  final List<Map<String, dynamic>> posts;
  final DocumentSnapshot? lastDoc;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasError;

  HomePostsState({
    this.posts = const [],
    this.lastDoc,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.hasError = false,
  });

  HomePostsState copyWith({
    List<Map<String, dynamic>>? posts,
    DocumentSnapshot? lastDoc,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? hasError,
  }) {
    return HomePostsState(
      posts: posts ?? this.posts,
      lastDoc: lastDoc ?? this.lastDoc,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      hasError: hasError ?? this.hasError,
    );
  }
}

class HomePostsNotifier extends StateNotifier<HomePostsState> {
  final HomePostsRepository _repo;

  HomePostsNotifier(this._repo) : super(HomePostsState());

  void setPosts(List<Map<String, dynamic>> posts, DocumentSnapshot? lastDoc, bool hasMore) {
    state = state.copyWith(
      posts: posts,
      lastDoc: lastDoc,
      isLoading: false,
      hasMore: hasMore,
      hasError: false,
    );
  }

  void updatePostLikeLocally(String postId, bool isLiked) {
    final updated = state.posts.map((post) {
      if (post['id'] == postId) {
        final currentLikes = (post['likes'] ?? 0) as int;
        return {
          ...post,
          'likedByCurrentUser': isLiked,
          'likes': isLiked ? currentLikes + 1 : currentLikes - 1,
        };
      }
      return post;
    }).toList();
    state = state.copyWith(posts: updated);
  }
}

final homePostsProvider =
    StateNotifierProvider<HomePostsNotifier, HomePostsState>((ref) {
  final repo = ref.watch(homePostsRepositoryProvider);
  return HomePostsNotifier(repo);
});
