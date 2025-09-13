import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation_bar/navigation_bar.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../auth/data/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  Stream<QuerySnapshot>? _loadPostsStream;
  String? _currentUserId;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Stream<QuerySnapshot> _loadPosts(String userId) {
    if (_loadPostsStream == null || _currentUserId != userId) {
      _currentUserId = userId;
      _loadPostsStream = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return _loadPostsStream!;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 5.h),
          child: Stack(
            children: [
              bodyHomePage(user, _loadPosts(user.uid)),
              Container(
                margin: EdgeInsets.only(top: 5.h),
                child: customAppBar()
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> likeAndUnlike(String postId, User user) async {
    final currentUserId = user.uid;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final ref = _firestore.collection('posts').doc(postId);
    final postData = await ref.get();
    final likedBy = postData['likedBy'] ?? [];

    if (likedBy.contains(currentUserId)) {
      await ref.update(
          {
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([currentUserId])
          }
      );
    }else {
      await ref.update(
          {
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([currentUserId])
          }
      );
    }
  }
  
  Widget bodyHomePage(User user, Stream<QuerySnapshot> loadPosts) {
    return StreamBuilder<QuerySnapshot>(
      stream: loadPosts,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('User posts stream error: ${snapshot.error}');
          String message = 'Something went wrong';
          return Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data?.docs ?? [];

        if (posts.isEmpty) {
          return Center(
              child: Text(
                "No posts yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              )
          );
        }

        return GridView.builder(
          padding: EdgeInsets.only(top: 55.h),
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;
            final imageUrl = data['imageUrl'] ?? '';

            return GestureDetector(
              onDoubleTap: () => likeAndUnlike(posts[index].id, user),
              onTap: () {
                print(data);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Center(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['caption'] ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 5.w,),
                      Text(
                        data['likes'].toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => likeAndUnlike(posts[index].id, user),
                        icon: data['likedBy'].contains(user.uid) ? Icon(
                          Icons.favorite,
                          size: 16.w,
                        ) :
                        Icon(
                          Icons.favorite_border_outlined,
                          size: 16.w,
                        ),
                      ),
                      SizedBox(width: 10.w,)
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget customAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      height: 40.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Board',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
