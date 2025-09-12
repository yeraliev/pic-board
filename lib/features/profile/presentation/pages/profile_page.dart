import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/settings/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';
import '../../../auth/data/providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Stream<QuerySnapshot>? _userPostsStream;
  String? _currentUserId;

  Stream<QuerySnapshot> _getUserPostsStream(String userId) {
    if (_userPostsStream == null || _currentUserId != userId) {
      _currentUserId = userId;
      _userPostsStream = FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return _userPostsStream!;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(user),
                SizedBox(height: 10.h),
                _buildBody(user, _getUserPostsStream(user.uid)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(User user, Stream<QuerySnapshot> userPostsStream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My posts',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        StreamBuilder<QuerySnapshot>(
          stream: userPostsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Log to console for debugging
              debugPrint('User posts stream error: ${snapshot.error}');
              // Show a friendly but informative message in UI
              final error = snapshot.error;
              String message = 'Something went wrong';
              if (error is FirebaseException) {
                message = '${error.code}: ${error.message}';
              } else {
                message = error.toString();
              }

              return Center(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data?.docs ?? [];

            if (posts.isEmpty) {
              return const Center(child: Text("No posts yet"));
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                  onTap: () {
                    print(data);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['caption'] ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
                            ),
                          ),
                          Icon(
                            Icons.favorite,
                            size: 16.w,
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
        ),
      ],
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.white,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!) as ImageProvider
                : const AssetImage('assets/images/user.png'),
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'No name',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Text(
                user.email ?? 'No email',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }
}
