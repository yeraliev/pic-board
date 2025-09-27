import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/board/presentation/pages/home_page.dart';
import '../../features/add_post/post_view/add_post_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class CustomBar extends StatefulWidget {
  final int? destination;
  const CustomBar({super.key, this.destination});

  @override
  State<CustomBar> createState() => _CustomBarState();
}
class _CustomBarState extends State<CustomBar>
    with AutomaticKeepAliveClientMixin {
  int selectedPage = 0;

  final listOfPages = [
    HomePage(key: PageStorageKey('home')),
    AddPostPage(key: PageStorageKey('addPost')),
    ProfilePage(key: PageStorageKey('profile')),
  ];

  final icons = [Icons.home_filled, Icons.add_circle, Icons.person];
  final titles = ['Home', 'Share', 'Profile'];

  @override
  void initState() {
    super.initState();
    // only set it the first time (when state is created fresh)
    selectedPage = widget.destination ?? 0;
  }

  @override
  void didUpdateWidget(covariant CustomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // don’t reset unless destination actually changed
    if (widget.destination != oldWidget.destination &&
        widget.destination != null) {
      selectedPage = widget.destination!;
    }
  }

  void onTappedIndex(int index) {
    if (!mounted) return;
    setState(() {
      selectedPage = index;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: IndexedStack(
        index: selectedPage,
        children: listOfPages,
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 45.w),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onInverseSurface,
              spreadRadius: 5.r,
              blurRadius: 7.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        height: 43.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            icons.length,
                (index) {
              final icon = icons[index];
              final title = titles[index];
              return GestureDetector(
                onTap: () => onTappedIndex(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: selectedPage == index ? 25.w : 20.w,
                        end: selectedPage == index ? 20.w : 25.w,
                      ),
                      builder: (context, size, child) => Icon(
                        icon,
                        size: size,
                        color: selectedPage == index
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.white54,
                      ),
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: selectedPage == index
                          ? Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                          : SizedBox.shrink(key: ValueKey('empty-$index')),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
