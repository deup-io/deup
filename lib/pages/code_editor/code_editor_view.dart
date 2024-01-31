import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:deup/common/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/code_editor/code_editor_controller.dart';

class CodeEditorPage extends GetView<CodeEditorController> {
  const CodeEditorPage({Key? key}) : super(key: key);

  /// NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        onPressed: () => Get.back(),
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(FontAwesomeIcons.xmark, size: CommonUtils.navIconSize),
      ),
      trailing: Container(
        width: 500.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              onPressed: () => Get.toNamed(Routes.WEBVIEW, arguments: {
                'url': 'https://docs.deup.io/guide/quick-start',
                'title': 'Deup!',
              }),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              child: Icon(CupertinoIcons.doc_text,
                  size: CommonUtils.isPad ? 20 : 60.sp),
            ),
            CupertinoButton(
              onPressed: () => controller.updateLink(),
              padding: EdgeInsets.zero,
              minSize: 33,
              alignment: Alignment.centerRight,
              child: Icon(CupertinoIcons.link_circle,
                  size: CommonUtils.isPad ? 22 : 65.sp),
            ),
            CupertinoButton(
              onPressed: () => controller.save(),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    if (controller.isLoading.isTrue) {
      return Center(child: CupertinoActivityIndicator());
    }

    return CodeTheme(
      data: CodeThemeData(
        styles: Get.isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
      ),
      child: Container(
        height: Get.height,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: CodeField(
            controller: controller.codeController,
            focusNode: controller.focusNode,
            background: Get.theme.scaffoldBackgroundColor,
            minLines: 30,
            wrap: true,
            lineNumbers: false,
            smartQuotesType: SmartQuotesType.disabled,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.floppyDisk,
            size: 38.sp,
            color: Colors.white,
          ),
          SizedBox(width: 10.w),
          Text('保存', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: SafeArea(
          child: BottomBar(
            width: 230.w,
            hideOnScroll: true,
            barColor: Get.theme.primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(50.r),
            child: SizedBox.shrink(),
            body: (context, controller) => Obx(() => _buildCodeField()),
          ),
        ),
      ),
    );
  }
}
