import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSnackBar{
  final Duration duration = const Duration(seconds: 3);

  void showSnackBar(BuildContext context,{required String text, required String type}) {
    final SnackBar snack;
    final errorSnackBar = SnackBar(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 10.w),
      margin: EdgeInsets.only(
        bottom: 10.h,
        left: 10.w,
        right: 10.w
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      content: Row(
        children: [
          Icon(
            Icons.error_rounded,
            color: Colors.red,
            size: 20.w,
          ),
          SizedBox(width: 10.w,),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          IconButton(onPressed: (){ScaffoldMessenger.of(context).hideCurrentSnackBar();}, icon: Icon(Icons.close_rounded, size: 18.w,))
        ],
      ),
    );
    final successSnackBar = SnackBar(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 10.w),
      margin: EdgeInsets.only(
          bottom: 10.h,
          left: 10.w,
          right: 10.w
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      content: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 18.w,
          ),
          SizedBox(width: 10.w,),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          IconButton(onPressed: (){ScaffoldMessenger.of(context).hideCurrentSnackBar();}, icon: Icon(Icons.close_rounded, size: 18.w,))
        ],
      ),
    );

    if(type=='error') {
      snack = errorSnackBar;
    }else if (type =='success') {
      snack = successSnackBar;
    } else {
      snack = errorSnackBar;
    }

    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
