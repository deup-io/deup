import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/pages/document/document_controller.dart';

class DocumentPage extends GetView<DocumentController> {
  const DocumentPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar? _buildNavigationBar() {
    // 隐藏导航栏
    if (controller.object.value.options != null &&
        controller.object.value.options!.hideNavBar != null &&
        controller.object.value.options!.hideNavBar!) {
      return null;
    }

    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Obx(
        () => Text(
          CommonUtils.formatFileNme(
              controller.object.value.name ?? controller.id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: controller.object.value.type == ObjectType.DOCUMENT
          ? PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: '添加到下载列表',
                  onTap: () => controller.download(),
                ),
              ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: showMenu,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size: CommonUtils.navIconSize,
                ),
              ),
            )
          : null,
    );
  }

  // WebView
  Widget _buildInAppWebView() {
    return InAppWebView(
      key: controller.webViewKey,
      initialUrlRequest: controller.data.value.isEmpty
          ? URLRequest(
              url: WebUri(controller.object.value.url ?? ''),
              headers: ObjectHelper.getHeaders(controller.object.value),
            )
          : null,
      initialData: controller.data.value.isNotEmpty
          ? InAppWebViewInitialData(data: controller.data.value)
          : null,
      initialSettings: controller.options,
      onProgressChanged: controller.onProgressChanged,
      onReceivedServerTrustAuthRequest: (app, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      shouldOverrideUrlLoading: (app, navigationAction) async {
        final uri = navigationAction.request.url!;

        /// 过滤掉不需要跳转的链接
        if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about']
            .contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  // PDF
  Widget _buildPdfView() {
    return Container(
      child: SfPdfViewer.network(
        controller.object.value.url ?? '',
        headers: ObjectHelper.getHeaders(controller.object.value),
        canShowScrollHead: true,
        canShowPaginationDialog: false,
        canShowPasswordDialog: false,
        canShowHyperlinkDialog: false,
        enableDoubleTapZooming: false,
      ),
    );
  }

  // 页面
  Widget _buildPageInfo() {
    if (controller.isLoading.isTrue) {
      return Center(child: CupertinoActivityIndicator());
    }

    // 代码类型
    if (PreviewHelper.isCode(controller.object.value.name ?? '') &&
        !PreviewHelper.isHtml(controller.object.value.name ?? '') &&
        controller.codeController != null) {
      return SingleChildScrollView(
        child: CodeTheme(
          data: CodeThemeData(
            styles: Get.isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
          ),
          child: CodeField(
            controller: controller.codeController!,
            enabled: false,
            minLines: 40,
            background: Get.theme.scaffoldBackgroundColor,
            lineNumberStyle: LineNumberStyle(margin: 0.r),
            lineNumbers: false,
          ),
        ),
      );
    }

    // PDF
    if (controller.fileType == 'pdf') return _buildPdfView();

    return Stack(
      children: [
        _buildInAppWebView(),
        controller.progress.value < 1.0
            ? LinearProgressIndicator(
                value: controller.progress.value,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              )
            : SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: BottomBar(
          width: Get.width,
          hideOnScroll: true,
          barColor: Colors.transparent,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () async {
                    if (controller.currentIndex.value == 0) {
                      SmartDialog.showToast('已经是第一个了');
                      return;
                    }

                    controller.currentIndex.value--;
                    await controller.getObjectInfo(
                        controller.objects[controller.currentIndex.value]);
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.chevron_up, size: 70.sp),
                ),
                CupertinoButton(
                  onPressed: () async {
                    if (controller.currentIndex.value ==
                        controller.objects.length - 1) {
                      SmartDialog.showToast('已经是最后一个了');
                      return;
                    }

                    controller.currentIndex.value++;
                    await controller.getObjectInfo(
                        controller.objects[controller.currentIndex.value]);
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.chevron_down, size: 70.sp),
                ),
                SizedBox(width: 20.w),
              ],
            ),
          ),
          body: (context, controller) => Obx(() => _buildPageInfo()),
        ),
      ),
    );
  }
}
