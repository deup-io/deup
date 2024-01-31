import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonHelper {
  /// 创建一个默认的按钮
  /// [text] 按钮文本
  /// [onPressed] 按钮点击事件
  /// [backgroundColor] 按钮背景颜色
  static createElevatedButton(
    String text, {
    required Function onPressed,
    Color? backgroundColor,
  }) {
    return ElevatedButton(
      child: Text(
        text,
        style: Get.textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: onPressed as void Function()?,
    );
  }
}
