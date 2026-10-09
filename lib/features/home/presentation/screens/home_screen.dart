import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/domain/usermodel.dart';
import '../../../auth/presentation/screens/signin_screen.dart';
import '../../../discussion/presentation/screens/addPost_screen.dart';
import '../../../discussion/presentation/screens/postView_screen.dart';
import '../../../jobs/presentation/screens/job_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/home_posts_repository.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final List listOfScreens = [
    const HomeScreen(),
    const JobScreen(),
    const PracticeScreen(),
  ];

  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Image.asset(
          'assets/images/logo3.png',
          width: 120,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.2),
          child: Container(
            color: Colors.grey.shade300,
            height: 0.08,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SigninScreen()),
                );
              }
            },
            child: const Icon(Icons.person_2_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: listOfScreens[selectedOption],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 0.09,
            color: Colors.grey.shade300,
            thickness: 0.15,
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedOption,
            backgroundColor: AppColors.bg,
            selectedItemColor: AppColors.textPrimary.withAlpha(200),
            unselectedItemColor: AppColors.textSecondary,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            onTap: (value) {
              setState(() {
                selectedOption = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Home",
                tooltip: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline_rounded),
                label: "Jobs",
                tooltip: "Jobs",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.data_object_sharp),
                label: "Practice",
                tooltip: "Practice",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _posts = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  bool _isGenerateError = false;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
    UserModel.loadPrefs().then((_) {
      if (mounted) {
        setState(() {
          currentUser = UserModel.currentUser;
        });
        if (currentUser != null) {
          ImageService.service?.loadImage(currentUser!.userName);
        }
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMorePosts();
      }
    });
  }

  /// Update like/unlike with optimistic UI
  Future<void> updateLike(String postId, String userId) async {
    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likedby')
        .doc(userId);

    final index = _posts.indexWhere((p) => p['id'] == postId);
    if (index == -1) return;

    final alreadyLiked = _posts[index]['likedByCurrentUser'] ?? false;

    // Optimistic UI
    setState(() {
      _posts[index]['likedByCurrentUser'] = !alreadyLiked;
      _posts[index]['likes'] =
          (_posts[index]['likes'] ?? 0) + (alreadyLiked ? -1 : 1);
    });

    try {
      if (alreadyLiked) {
        await likeRef.delete();
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'likes': FieldValue.increment(-1)});
      } else {
        await likeRef.set({
          'userId': userId,
          'likedAt': FieldValue.serverTimestamp(),
          'username': currentUser?.userName ?? "Unknown",
        });
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'likes': FieldValue.increment(1)});
      }
    } catch (e) {
      // Rollback if Firestore fails
      if (mounted) {
        setState(() {
          _posts[index]['likedByCurrentUser'] = alreadyLiked;
          _posts[index]['likes'] =
              (_posts[index]['likes'] ?? 0) + (alreadyLiked ? 1 : -1);
        });
      }
    }
  }

  /// Load initial posts
  Future<void> _loadInitialPosts() async {
    setState(() {
      _isInitialLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('time', descending: true)
          .limit(6)
          .get();

      final currentUserId =
          UserModel.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      _posts = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        data['id'] = doc.id;

        if (currentUserId != null) {
          final likeDoc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .collection('likedby')
              .doc(currentUserId)
              .get();
          data['likedByCurrentUser'] = likeDoc.exists;
        } else {
          data['likedByCurrentUser'] = false;
        }
        return data;
      }).toList());

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _hasMore = snapshot.docs.length == 6;
          _isGenerateError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
          _isGenerateError = true;
        });
      }
    }
  }

  /// Pull-to-refresh
  Future<void> _refreshPosts() async {
    _lastDoc = null;
    _hasMore = true;
    _posts.clear();
    await _loadInitialPosts();
  }

  /// Load more posts (pagination)
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('time', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(6)
          .get();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;

        final newPosts = await Future.wait(snapshot.docs.map((doc) async {
          final data = doc.data();
          data['id'] = doc.id;

          if (currentUserId != null) {
            final likeDoc = await FirebaseFirestore.instance
                .collection('posts')
                .doc(doc.id)
                .collection('likedby')
                .doc(currentUserId)
                .get();
            data['likedByCurrentUser'] = likeDoc.exists;
          } else {
            data['likedByCurrentUser'] = false;
          }
          return data;
        }).toList());

        _posts.addAll(newPosts);
      }

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMore = snapshot.docs.length == 6;
          _isGenerateError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _isGenerateError = true;
        });
      }
    }
  }

  String formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} month ago';
    return '${(diff.inDays / 365).floor()} year ago';
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isGenerateError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Something Went Wrong.."),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  _loadInitialPosts();
                },
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final post = _posts[index];
            final timestamp = post['time'] as Timestamp?;
            final convertedDate = timestamp?.toDate() ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.bg2,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostViewScreen(postData: post),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                              post['profile'] ??
                                  "https://raw.githubusercontent.com/bsv15/my_flutter_app/refs/heads/main/profile.jpeg",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['username'] ?? "Unknown",
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatTime(convertedDate),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        post['description'] ?? "",
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Action Row
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              final currentUserId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (currentUserId != null) {
                                updateLike(post['id'], currentUserId);
                              }
                            },
                            child: post['likedByCurrentUser'] == true
                                ? const Icon(Icons.favorite,
                                    color: Colors.redAccent)
                                : const Icon(Icons.favorite_border,
                                    color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Text(((post['likes'] ?? 0) as int).toString()),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment_outlined,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(((post['comments'] ?? 0) as int).toString()),
                          const Spacer(),
                          InkWell(
                            onTap: () async {
                              final response = await http.get(Uri.parse(
                                  "https://cdn.jsdelivr.net/gh/bsv15/my_flutter_app@main/Share_Ref/share_new.txt"));
                              if (response.statusCode == 200) {
                                String template = response.body;
                                String username = post['username'] ?? "";
                                String desc = (post['description'] ?? "")
                                    .toString()
                                    .split('\n')
                                    .first
                                    .trim();
                                String shareText = template
                                    .replaceAll('{{username}}', username)
                                    .replaceAll('{{description}}', desc)
                                    .replaceAll('{{link}}', 'www.google.com');

                                Share.share(shareText,
                                    subject: "Chhaatra APP, Download Now");
                              }
                            },
                            child: const Icon(Icons.share_outlined,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        backgroundColor: AppColors.bg,
        tooltip: "New Post",
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}
